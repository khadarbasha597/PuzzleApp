import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/Screens/loginpage.dart';
import '../main.dart';
import '../workpage.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false; // Default is light mode
  User? user;
  String? name;
  String? email;
  int points = 0;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        name = userData['name'];
        email = userData['email'];
        points = userData['points'];
      });
    }
  }


  void _changeTheme(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _isDarkMode = isDarkMode;
      if (isDarkMode) {
        themeProvider.setTheme(ThemeData.dark());
      } else {
        themeProvider.setTheme(ThemeData.light());
      }
    });
  }

  Widget _buildDecoratedTile(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildThemeToggle() {
    return ListTile(
      leading: Icon(Icons.brightness_6),
      title: Text(
        'Theme',
        style: TextStyle(fontSize: 16),
      ),
      trailing: GestureDetector(
        onTap: () {
          _changeTheme(!_isDarkMode);
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              SizedBox(width: 8),
              Text(_isDarkMode ? 'Dark' : 'Light',style: TextStyle(fontSize: 16),),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: _isDarkMode ? Colors.grey : Colors.blue,
        shadowColor: _isDarkMode ? Colors.grey : Colors.blue,
        elevation: 6,
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          Container(
            height: 170,
            decoration:BoxDecoration(
              color:  _isDarkMode ? Colors.grey: Colors.blue,
            ) ,

            child: Padding(
              padding: const EdgeInsets.only(left: 10,top:5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 58,
                  ),
                  SizedBox(width: 6,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 41,),
                      Text('$name,',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      SizedBox(height:  2,),
                      SingleChildScrollView(
                          child: Text('$email',style: TextStyle(fontSize: 14),)
                      ),
                      SizedBox(height:  2,),
                      Text('Points:$points',style: TextStyle(fontSize: 16),),
                      Row(
                        children: [
                          SizedBox(width: 180,),
                          IconButton(
                            onPressed: (){},
                            icon:Icon(Icons.edit),),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          _buildDecoratedTile(_buildThemeToggle()),
          _buildDecoratedTile(
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notification Settings'),
              onTap: () {
                // Handle tap
              },
            ),
          ),
          _buildDecoratedTile(
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                // Handle tap
                // Navigator.push(
                //     context,
                //   MaterialPageRoute(builder: (context)=>UploadImageScreen()),
                // );
              },
            ),
          ),
          Divider(),
          _buildDecoratedTile(
            ListTile(
              leading: Icon(Icons.support),
              title: Text('Challenge to Friend'),
              onTap: () {
                // Handle tap
              },
            ),
          ),
          _buildDecoratedTile(
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Terms of Service'),
              onTap: () {
                // Handle tap
              },
            ),
          ),
          _buildDecoratedTile(
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle tap
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context){
                      return MyApp();
                    })
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
