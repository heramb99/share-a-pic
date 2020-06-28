
import './main.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sharepic/HomePage.dart';
import './Animation/FadeAnimation.dart';
import 'package:flutter/services.dart';
import 'dart:async' show Future;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';


class SignUpForm extends StatefulWidget{
  final String mobile;

  SignUpForm({this.mobile});
  @override
  State<StatefulWidget> createState() {
    return SignUpFormState(mobile: mobile);
  }
}

class SignUpFormState extends State<SignUpForm>{

  final String mobile;

  SignUpFormState({this.mobile});

  ProgressDialog progressDialog;
  
  TextEditingController dobController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _name;
  String _email;
  String _password;
  String _dob;

  String validateName(String value) {
    if (value.length <= 2)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length <6)
      return 'Password length should be greater than 6';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  Future<bool> checkConnectivity() async{
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException catch (_) {
        return false;
      }
      return false;
    }

  
  Future _validateInputs(BuildContext context) async {
    

    if (_formKey.currentState.validate()) {
  //    If all data are correct then save data to out variables
      _formKey.currentState.save();
      
    FirebaseUser user;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    
    try {

        //creating account using email and password
        AuthResult result = await _auth.createUserWithEmailAndPassword(
        email:_email,
        password: _password,
      ); 

      user=result.user;
    } catch (e) {
      print(e.toString());
    } finally {
      if (user != null) {

        Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage(user: user)));

      }else{
        Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1
        );
      }
    }
    } else {
  //    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
}

  
  @override
  Widget build(BuildContext context) {

     progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    // progressDialogDelete = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    progressDialog.style(
      message: 'Connecting...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange[900],
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
        backgroundColor: Colors.white,
        body:SafeArea(
              child: Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Positioned(
                          child:FadeAnimation(1, Container(
                            decoration: BoxDecoration(
                              border: Border(
                                    top : BorderSide(color:Colors.deepOrange[900]),
                                  ),
                              image: DecorationImage(
                                image:AssetImage('assets/images/orange_background.jpg'),
                                fit:BoxFit.fill
                              )
                            ),
                          ) 
                        )
                        ),
                        FadeAnimation(1.2,Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'Share',style: TextStyle(color:Colors.white,fontSize: 50),
                                  children: <TextSpan>[
                                    TextSpan(text: 'Pic', style: TextStyle(color:Colors.orange[500],fontSize: 50))
                                    ]
                                  )
                                ),
                              ],
                            ),
                        ) 
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: <Widget>[
                        FadeAnimation(1.5, Text(LoginPageState().strings["signUpTitle"],style: TextStyle(color:Colors.orange[900],fontSize: 30,fontWeight:FontWeight.bold),)),
                        SizedBox(height: 25,),
                        FadeAnimation(1.7, Container(
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
                          child: Form(
                              key: _formKey,
                              autovalidate: _autoValidate,
                              child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color:Colors.grey[300])
                                    )
                                  ),
                                  child: TextFormField(
                                  onSaved:(val) => _name=val,
                                  validator: validateName,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person,color: Colors.grey,),
                                    border:InputBorder.none,
                                    hintText: LoginPageState().strings["nameHint"],
                                    hintStyle: TextStyle(color:Colors.grey)
                                  ),
                                    ),
                                ),
                                Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color:Colors.grey[300])
                                  )
                                ),
                                child: TextFormField(
                                  onSaved:(val) =>_email=val,
                                  validator: validateEmail,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.contact_mail,color: Colors.grey,),
                                    border:InputBorder.none,
                                    hintText: LoginPageState().strings["emailHint"],
                                    hintStyle: TextStyle(color:Colors.grey)
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color:Colors.grey[300])
                                  )
                                ),
                                child: TextFormField(
                                  controller: dobController,
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(new FocusNode());

                                    DateTime picked = await showDatePicker(
                                        context: context,
                                        initialDate: new DateTime.now(),
                                        firstDate: new DateTime(1970),
                                        lastDate: new DateTime(2021)
                                    );
                                    if(picked != null) setState(() => dobController.text = (picked.day).toString()+"-"+(picked.month).toString()+"-"+(picked.year).toString());
                                  },
                                  
                                  onSaved:(val) =>_dob=val,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.calendar_today,color: Colors.grey,),
                                    border:InputBorder.none,
                                    hintText: LoginPageState().strings["dobHint"],
                                    hintStyle: TextStyle(color:Colors.grey)
                                  ),
                                  
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color:Colors.grey[300])
                                  )
                                ),
                                child: TextFormField(
                                  obscureText: true,
                                  onSaved:(val) =>_password=val,
                                  validator: validatePassword,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock,color: Colors.grey,),
                                    border:InputBorder.none,
                                    hintText: LoginPageState().strings["passwordHint"],
                                    hintStyle: TextStyle(color:Colors.grey)
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                ),
                              ),
                              ],
                            ),
                          ),
                        )
                        ,),
                        SizedBox(height: 30,),
                        FadeAnimation(1.9, Container(
                          height: 40,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.orange[900]
                            ),
                          child: SizedBox(
                              width:200 ,
                              child: RaisedButton(
                              color: Colors.orange[900],
                              child: Center(
                                child:Text(LoginPageState().strings["signUpFormButton"],style: TextStyle(color:Colors.white),)
                                ),
                              onPressed: () {
                                checkConnectivity().then((value) {
                                  if(value){
                                    _validateInputs(context);
                                  }else{
                                    Fluttertoast.showToast(
                                        msg: "No Internet Connnection",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1
                                      );
                                  }
                                });
                              },
                            ),
                          )
                        ),
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  )
                ],
            ),
          ),
        ),
      )
    );

  }
}