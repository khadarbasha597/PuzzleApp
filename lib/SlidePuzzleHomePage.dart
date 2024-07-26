import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/Screens/Notificationpage.dart';
import 'Screens/settingspage.dart';
import 'Screens/theme_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SlidePuzzleHomePage extends StatefulWidget {
  final Image? solvedImage;
  SlidePuzzleHomePage({Key? key, this.solvedImage}) : super(key: key);

  @override
  _SlidePuzzleHomePageState createState() => _SlidePuzzleHomePageState();
}

class _SlidePuzzleHomePageState extends State<SlidePuzzleHomePage>
    with TickerProviderStateMixin {
  late List<int> tiles;
  late int gridSize;
  int moveCount = 0;
  Timer? timer;
  int secondsPassed = 0;
  bool isTimerPaused = false;
  bool isSolved = false;
  bool reset=false;
  File? _selectedImage;
  bool timerStarted = false;
  int coins = 0;
  File? _image;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<Offset> _puzzleAnimation;
  late Animation<Offset> _imageAnimation;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  @override
  void initState() {
    super.initState();
    gridSize = 4; // Default grid size
    _initializeTiles();

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _puzzleAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _imageAnimation = Tween<Offset>(
      begin: Offset(1.0, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _coinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.easeInOut,
    ));
    _fetchCoins();
  }
  void _fetchCoins() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        coins = userDoc['points'];
      });
    }
  }


  void _initializeTiles() {
    tiles = List<int>.generate(gridSize * gridSize, (index) => index);
    tiles.shuffle();
    moveCount = 0;
    secondsPassed = 0;
    isSolved = false;
  }

  void _resetTiles() {
    setState(() {
      _initializeTiles();
      _animationController.reset(); // Reset animation when tiles are reset

      // Check if the puzzle was solved before the reset
      if (isSolved) {
        _selectedImage = null; // Reset the selected image
      }

      isSolved = false; // Reset the isSolved flag
      timerStarted = false; // Reset the timerStarted flag
    });
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!isTimerPaused && !isSolved) {
        setState(() {
          secondsPassed++;
        });
      }
    });
  }

  void _stopTimer() {
    timer?.cancel();
  }

  void _moveTile(int index) {
    if (isTimerPaused || isSolved) return;

    int blankIndex = tiles.indexOf(0);
    if ((index - 1 == blankIndex && index % gridSize != 0) ||
        (index + 1 == blankIndex && (index + 1) % gridSize != 0) ||
        (index - gridSize == blankIndex) ||
        (index + gridSize == blankIndex)) {
      setState(() {
        tiles[blankIndex] = tiles[index];
        tiles[index] = 0;
        moveCount++;
      });

      if (!timerStarted) {
        _startTimer(); // Start the timer on the first move
        timerStarted = true;
      }

      if (_isSolved()) {
        _stopTimer(); // Stop the timer when the puzzle is solved
        _onPuzzleSolved(); // Handle puzzle solved logic
      }
    }
  }
  Future<void> _addPointsToFirebase(int pointsToAdd) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Get a reference to the user's document in Firestore
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        print(user.uid);
        // Use a transaction for atomic updates
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userRef);
          if (snapshot.exists) {
            int currentPoints = snapshot.get('points') ?? 0;
            int newPoints = currentPoints + pointsToAdd;

            // Update the points field in Firestore
            transaction.update(userRef, {'points': newPoints});
          }
        });
      }
    } catch (e) {
      print('Error adding points to Firestore: $e');
    }
  }

  void _onPuzzleSolved() {
    setState(() {
      isSolved = true;
      if (gridSize == 3) {
        coins += 10;
      } else if (gridSize == 4) {
        coins += 20;
      } else if (gridSize == 5) {
        coins += 40;
      }
      _animationController.forward(); // Start puzzle animation
      _coinAnimationController.forward(from: 0); // Start coin animation
    });
    if (gridSize == 3) {
      _addPointsToFirebase(10);
    } else if (gridSize == 4) {
      _addPointsToFirebase(20);
    } else if (gridSize == 5) {
      _addPointsToFirebase(40);
    }

  }

  bool _isSolved() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[tiles.length - 1] == 0;
  }

  String getFormattedTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _togglePauseTimer() {
    if (!isSolved) {
      setState(() {
        isTimerPaused = !isTimerPaused;
      });
    }
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _uploadImage();
      });
      Fluttertoast.showToast(
          msg: 'Image Selected',
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 20
      );
    }

  }
  Future<void> _uploadImage() async {
    if ( _selectedImage == null) return;

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      String uid = user.uid;
      String fileName = 'images/${uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile( _selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded. Download URL: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  Widget _buildBody() {
    if (_selectedImage != null) {
      // Display the selected image
      return SlideTransition(
        position: _imageAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            child: Image.file(_selectedImage!, fit: BoxFit.cover),
          ),
        ),
      );
    } else {
      // Display congratulations message
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'You have Solved the Puzzle!',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Time: ${getFormattedTime(secondsPassed)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Moves: $moveCount',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Coins: $coins',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          FadeTransition(
            opacity: _coinAnimation,
            child: Icon(
              Icons.monetization_on,
              size: 50,
              color: Colors.yellow,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: isDarkMode ? Colors.grey : Colors.blue,
        shadowColor: isDarkMode ? Colors.grey : Colors.blue,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Column(
          children: [
            SizedBox(height: 20,),
            Text(
              'Slide Puzzle',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(right: 64),
              child: Text(
                'Points: $coins',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            iconSize: 30,
            onSelected: (value) {
              if (value == 6) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              } else if (value == 7) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Notificationpage(),
                  ),
                );

              } else {
                _changeGridSize(value);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 7,
                child: Row(
                  children: [
                    Text('Notifications',style: TextStyle(fontSize: 16),),
                    SizedBox(width: 10),
                    InkWell(
                      onDoubleTap: (){
                        _selectImage(); // Select Image

                      },
                      child: Icon(Icons.notifications),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: Text('3x3 Puzzle',style: TextStyle(fontSize: 16),),
              ),
              PopupMenuItem<int>(
                value: 4,
                child: Text('4x4 Puzzle',style: TextStyle(fontSize: 16),),
              ),
              PopupMenuItem<int>(
                value: 5,
                child: Text('5x5 Puzzle',style: TextStyle(fontSize: 16),),
              ),
              PopupMenuItem<int>(
                value: 6,
                child: Text('Settings',style: TextStyle(fontSize: 16),),

              ),
            ],
          ),
          IconButton(
            iconSize: 35,
            icon: Icon(isTimerPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePauseTimer,
          ),
          SizedBox(width: 6,),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SlideTransition(
                position: _puzzleAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50,right: 2,left: 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Time: ${getFormattedTime(secondsPassed)}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 100),
                          Text(
                            'Moves: $moveCount',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                          ),
                          itemCount: tiles.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _moveTile(index),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                margin: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: tiles[index] == 0
                                      ? Colors.white
                                      : (isDarkMode ? Colors.grey : Colors.blue),
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    tiles[index] == 0 ? '' : tiles[index].toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSolved)
                Positioned.fill(
                  child: _buildBody(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetTiles,
        tooltip: 'Restart',
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _coinAnimationController.dispose();
    _stopTimer();
    super.dispose();
  }

  void _changeGridSize(int newSize) {
    setState(() {
      gridSize = newSize;
      _resetTiles();
    });
  }
}
