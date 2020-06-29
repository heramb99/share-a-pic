import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharepic/HomePage.dart';
import 'package:sharepic/main.dart';
import 'ProfilePage.dart';
import 'Strings.dart';

class NavDrawer extends StatelessWidget {

  final FirebaseUser user;
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  NavDrawer({this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Center(
              child: Icon(Icons.person_outline,color: Colors.white,size: 60,),
            ),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/header_image.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(Strings().home,style: TextStyle(color:Colors.black),),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => HomePage(user:user)));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(Strings().profile,style: TextStyle(color:Colors.black),),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user,)));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Strings().logout,style: TextStyle(color:Colors.black),),
            onTap: () async{
              await _firebaseAuth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
