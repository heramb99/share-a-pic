import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 1),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[900],
      body: Center(
        child: RichText(
          text: TextSpan(
            text: 'Share',
            style: TextStyle(color:Colors.white,fontSize: 50),
            children: <TextSpan>[
              TextSpan(text: 'Pic', style: TextStyle(color:Colors.orange[500],fontSize: 50))
            ]
          )
        ),
      ),
    );
  }
}