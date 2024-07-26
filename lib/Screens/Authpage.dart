import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'signuppage.dart';
class authpage extends StatefulWidget {
  const authpage({super.key});

  @override
  State<authpage> createState() => _authpageState();
}

class _authpageState extends State<authpage> {
  bool lpage =true;
  void toggleScreens(){
    setState(() {
      lpage=!lpage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(lpage){
      return LoginPage(
        Rpage:toggleScreens,
      );
    }else{
      return SignUpPage(
          lpage: toggleScreens,
      );
    }
  }
}
