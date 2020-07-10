
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'Animation/FadeAnimation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async' show Future;
import './main.dart';
import './SignUpForm.dart';
import './Strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';



class PhoneSignPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return PhoneSignPageState();
  }
}

class PhoneSignPageState extends State<PhoneSignPage>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  String _mobile;
  Country _countryCode=Country.IN;

  String validateMobile(String value) {
    if (value.length < 10 || value.length>15)
      return 'Invalid Length';
    else
      return null;
  }

  
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future _validateInputs(BuildContext context) async{
    _formKey.currentState.save();

    if(_formKey.currentState.validate()){

      FirebaseAuth _auth=FirebaseAuth.instance;
      print(_countryCode.dialingCode+_mobile);
      
      //verifying mobile number
      _auth.verifyPhoneNumber(
        phoneNumber: "+"+_countryCode.dialingCode+_mobile, 
        timeout: Duration(seconds: 60), 
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();

          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => SignUpForm(mobile: "+"+_countryCode.dialingCode+_mobile,)
          ));

        }, 
        verificationFailed: (AuthException exception){
          print(exception);
        }, 
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Enter OTP"),
                content:  PinEntryTextField(
                  fields: 6,
                  fieldWidth: 20.0,
                  showFieldAsBox: false,
                  isTextObscure: false,
                  fontSize: 15.0,
                  onSubmit: (String pin) async{
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => SignUpForm(mobile: "+"+_countryCode.dialingCode+_mobile,)));
                  },
                )
              );
            }
          );
        },
        codeAutoRetrievalTimeout: null
      );

    }else{
      setState(() {
        _autoValidate = true;
      });
    }
  }
  
  //checking internet connection
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

  @override
  Widget build(BuildContext context) {

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
                        FadeAnimation(1.5, Text(Strings().signUpTitle,style: TextStyle(color:Colors.orange[900],fontSize: 30,fontWeight:FontWeight.bold),)),
                        SizedBox(height: 25,),
                        FadeAnimation(1.7, 
                          Container(
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
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color:Colors.grey[300])
                                    )
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(padding:EdgeInsets.only(right: 10), child: Icon(Icons.contact_phone,color: Colors.grey)),
                                      CountryPicker(
                                        
                                        dense: false,
                                        showFlag: true,  //displays flag, true by default
                                        showDialingCode: true, //displays dialing code, false by default
                                        showName: false, //displays country name, true by default
                                        showCurrency: false, //eg. 'British pound'
                                        showCurrencyISO: true, //eg. 'GBP'
                                        onChanged: (Country country) {
                                          setState(() {
                                            _countryCode=country;
                                          });
                                        },
                                        selectedCountry: _countryCode,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                          onSaved:(val) =>_mobile=val,
                                          validator: validateMobile,
                                          decoration: InputDecoration(
                                            border:InputBorder.none,
                                            hintText: Strings().mobileHint,
                                            hintStyle: TextStyle(color:Colors.grey)
                                          ),
                                          keyboardType: TextInputType.phone
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          )
                        ),
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
                                child:Text(Strings().signupButton,style: TextStyle(color:Colors.white),)
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
                        FadeAnimation(2.0,Center(
                          child:InkWell(
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: RichText(
                                text: TextSpan(
                                text: Strings().logInLinkText, style: TextStyle(color: Colors.black, fontSize: 17),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' Log In', 
                                    style: TextStyle(color: Colors.orange[900], fontSize: 17),
                                    recognizer: TapGestureRecognizer()
                                    ..onTap=(){
                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                                    }
                                  )
                                ]
                                ),
                              ),
                            )
                          )
                        )
                      )
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