import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'forgotpasswordpage.dart';

class LoginPage extends StatefulWidget {
  @override
  final VoidCallback Rpage;
  LoginPage({super.key,required this.Rpage});
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email=TextEditingController();
  final _pass=TextEditingController();
  var _isObscured=true;
  Future signin() async {
    try{
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password:_pass.text.trim(),
      );
    }on FirebaseAuthException catch (e){
      print(e);
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
                content:Container(
                  height: 122,
                  child: Column(
                      children: [
                        Text(
                          'User not Exist',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ) ,
                        SizedBox(height: 5,),
                        Text(
                          'check Email and Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ) ,
                        SizedBox(height: 17,),
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
                      ]
                  ),
                )
            );
          }
      );
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _pass.dispose();
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
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Fill out the information below in order to access your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _pass,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: _isObscured? Icon(Icons.visibility_off):Icon(Icons.visibility),

                              onPressed: (){
                                setState(() {
                                  _isObscured =!_isObscured;
                                });
                              }
                              ,),
                          ),
                          obscureText: _isObscured,
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context){
                                      return ForgotPasswordPage();
                                    })
                                );
                              },
                              child: Text('Forgot Password?'
                                ,style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            signin();
                          },
                          child: Text('Sign In',style: TextStyle(fontSize: 16),),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0), backgroundColor: Colors.blue,
                            minimumSize: Size(double.infinity, 36),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Or sign in with'),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.g_mobiledata,
                          color: Colors.red,
                            size: 40,
                          ),
                          label: Text('Continue with Google',style: TextStyle(fontSize: 16),),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.Rpage ,
                              child: Text(
                                'SignUp here',
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
