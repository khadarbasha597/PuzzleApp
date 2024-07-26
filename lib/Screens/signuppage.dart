import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/SlidePuzzleHomePage.dart';

class SignUpPage extends StatefulWidget {
  @override
  final VoidCallback lpage;
  SignUpPage({super.key, required this.lpage});
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass1 = TextEditingController();
  var _isObscured = true;
  var _isObscured1 = true;

  Future signup() async {
    if (_validateFields()) {
      try {
        // New user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
        // Add user details
        await addUserDetails(
          _name.text.trim(),
          _email.text.trim(),
          _pass.text.trim(),
        );
        // Navigate to home page or show success message
      } on FirebaseAuthException catch (e) {
        _showDialog(e.message!);
      } catch (e) {
        _showDialog("An unknown error occurred.");
      }
    }
  }

  Future addUserDetails(String name, String email, String pass) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    String uid = user.uid;
    CollectionReference users = firestore.collection('users');
    await users.doc(uid).set({
      'uid':uid,
      'name': name,
      'email': email,
      'pass': pass,
      'points':0,
    });
  }

  bool _validateFields() {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _pass.text.isEmpty ||
        _pass1.text.isEmpty) {
      _showDialog("All fields are required.");
      return false;
    }
    if (_pass.text != _pass1.text) {
      _showDialog("Passwords do not match.");
      return false;
    }
    if (!_email.text.contains('@')) {
      _showDialog("Invalid email address.");
      return false;
    }
    return true;
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error:-',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ) ,
          content: Text(
              message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ok',style: TextStyle(fontSize: 16),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 36),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _pass1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.orange],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Puzzle.App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Let\'s get started by filling out the form below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _pass,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: _isObscured
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                          obscureText: _isObscured,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _pass1,
                          decoration: InputDecoration(
                            labelText: 'Re-Password',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: _isObscured1
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isObscured1 = !_isObscured1;
                                });
                              },
                            ),
                          ),
                          obscureText: _isObscured1,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            signup();
                          },
                          child: Text('Create Account'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: Colors.blue,
                            minimumSize: Size(double.infinity, 36),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Or sign up with'),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.g_mobiledata,
                            color: Colors.red,
                            size: 40,
                          ),
                          label: Text(
                            'Continue with Google',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'I have an account?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.lpage,
                              child: Text(
                                'SignIn here',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
