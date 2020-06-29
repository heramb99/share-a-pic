import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import './NavDrawer.dart';
import './Strings.dart';
import './main.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseUser user;

  ProfilePage({this.user});
  @override
  _ProfilePageState createState() => _ProfilePageState(user:user);
}

class _ProfilePageState extends State<ProfilePage> {

  final FirebaseUser user;
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  _ProfilePageState({this.user});

  //list for storing user info
  List info=List<String>();

  final dbRef = FirebaseDatabase.instance.reference().child("users");
  

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
      drawer: NavDrawer(user:user),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: FutureBuilder(
                  future: dbRef.child(user.uid).once(),
                  builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting){
                      return Container(
                        child: Center(
                          child:Text(Strings().loading,style: TextStyle(color:Colors.black),)
                        ),
                      );
                    }
                    if (snapshot.hasData){
                      info.clear();
                      Map<dynamic, dynamic> values = snapshot.data.value;
                      values.forEach((key, values) {
                          info.add(values);
                      });
                      return Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.fromLTRB(20,50,20,20),
                            height: 80,
                            width: 80,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:AssetImage('assets/images/user_profile.png'),
                                fit:BoxFit.fill
                              )
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20,10,20,10),
                            height: 60,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:Color.fromRGBO(196, 135, 198, 1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                                )
                              ]
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.perm_identity),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(info[2],style: TextStyle(color:Colors.black,fontSize: 18),),
                                )
                              ],
                            )
                          ),
                          SizedBox(height: 20,),
                          Container(
                            height: 60,
                            margin:EdgeInsets.fromLTRB(20,10,20,10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:Color.fromRGBO(196, 135, 198, 1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                                )
                              ]
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.email),
                                Expanded(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(info[3],style: TextStyle(color: Colors.black,fontSize: 18),),
                                )),
                                InkWell(
                                  onTap: ()async{
                                    if (user.isEmailVerified==false){
                                      user.sendEmailVerification();
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        child:AlertDialog(
                                        title:Text('Alert'),
                                        content: Text('Verify your account by clicking on link in the mail.Then login again'),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed:()async {
                                              Navigator.pop(context);
                                              await _firebaseAuth.signOut();
                                              Navigator.pushReplacement(context, MaterialPageRoute(
                                              builder: (context) => LoginPage()));
                                            }, 
                                            child: Text('Ok')
                                            ),
                                          ],
                                        )
                                      );
                                    }
                                  },
                                  child: user.isEmailVerified? 
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.verified_user,color: Colors.green,),
                                      Text(Strings().verified,style:TextStyle(color: Colors.black) ),
                                    ],
                                  ):Row(
                                    children: <Widget>[
                                      Icon(Icons.error_outline,color: Colors.red,),
                                      Text(Strings().unverified,style:TextStyle(color: Colors.black) ),
                                    ],
                                  )
                                )
                              ],
                            )
                          ),
                          SizedBox(height: 20,),
                          Container(
                            height: 60,
                            padding: EdgeInsets.all(10),
                            margin:EdgeInsets.fromLTRB(20,10,20,10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:Color.fromRGBO(196, 135, 198, 1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                                )
                              ]
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.calendar_today),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(info[0],style: TextStyle(color:Colors.black,fontSize: 18),),
                                )
                              ],
                            )
                          ),
                          SizedBox(height: 30,),
                          Container(
                            height: 60,
                            margin: EdgeInsets.fromLTRB(20,10,20,10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:Color.fromRGBO(196, 135, 198, 1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                                )
                              ]
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.phone),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(info[1],style: TextStyle(color:Colors.black,fontSize: 18),),
                                )
                              ],
                            )
                          ),
                          
                        ],
                      );
                    }
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}