
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './NavDrawer.dart';

class HomePage extends StatefulWidget {

  final FirebaseUser user;

  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState(user:user);
}

class _HomePageState extends State<HomePage> {

  final FirebaseUser user;

  _HomePageState({this.user});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Share',style: TextStyle(color:Colors.white,fontSize: 30),
            children: <TextSpan>[
              TextSpan(text: 'Pic', style: TextStyle(color:Colors.orange[500],fontSize: 30))
            ]
          )
        ),
        backgroundColor: Colors.orange[900],
      ),
      drawer: NavDrawer(),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("You are Logged in succesfully", style: TextStyle(color: Colors.lightBlue, fontSize: 32),),
            SizedBox(height: 16,),
            Text("${user.email}+" "${user.isEmailVerified.toString()}", style: TextStyle(color: Colors.grey, ),),
          ],
        ),
      ),
    );
  }
}