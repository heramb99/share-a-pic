
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './Animation/FadeAnimation.dart';
import 'package:flutter/services.dart';
import './SplashPage.dart';
import 'dart:convert' show jsonDecode;
import 'dart:async' show Future;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import './HomePage.dart';
import 'VerifyPhone.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  var name=pref.getString('name');
  // print(name+" checking");
  var userid=pref.getInt('userid');
  runApp(
    MaterialApp(
      home: SplashScreen(),
      routes: {
        '/loginpage':(context) =>LoginPage(),
        '/signpage':(context)=>PhoneSignPage(),
        '/homepage':(context)=>HomePage(),
      },
    )
  );
}

class LoginPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage>{


  ProgressDialog progressDialog;
  var strings;
  
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //loading strings.json file
  Future<String>_loadFromAsset() async {
    return await rootBundle.loadString("assets/strings/en.json");
  }

Future parseStringsJson() async {
    String jsonString = await _loadFromAsset();
    strings = await jsonDecode(jsonString);
    print(strings);
}

  Future<void> checkForLogin(String email,String password,BuildContext context) async{

    progressDialog.show();
    final ioc = new HttpClient();
        ioc.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        final http = new IOClient(ioc);
    var url = 'https://digitalboard.salmonjoy.com/app/login-app.php';
    var loginresponse = await http.post(url,body: {'email':email,'password': password});


    if(loginresponse.statusCode==200){
      var res=jsonDecode(loginresponse.body);
      // print(res);
      if(res['status']){
        progressDialog.hide();
        // SharedPreferences pref = await SharedPreferences.getInstance();
        // pref.setString('name', res['name']);
        // pref.setInt('userid', int.parse(res['userid']));
        // Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>FolderPage(name:res['name'],userid:int.parse(res['userid']))));
      }else{
        progressDialog.hide();
        Fluttertoast.showToast(
          msg: "Invalid Credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1
        );
      }
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

    parseStringsJson();

     progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

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
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(1.5, Text(strings["loginTitle"],style: TextStyle(color:Colors.orange[900],fontSize: 30,fontWeight:FontWeight.bold),)),
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
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color:Colors.grey[300])
                                )
                              ),
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email,color: Colors.grey,),
                                  border:InputBorder.none,
                                  hintText: strings["emailHint"],
                                  hintStyle: TextStyle(color:Colors.grey)
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline,color: Colors.grey,),
                                  border:InputBorder.none,
                                  hintText: strings["passwordHint"],
                                  hintStyle: TextStyle(color:Colors.grey)
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      ,),
                      SizedBox(height: 30,),
                      FadeAnimation(1.9, Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.orange[900]
                          ),
                        child: RaisedButton(
                          color: Colors.orange[900],
                          child: Center(
                            child:Text(strings["loginButtonText"],style: TextStyle(color:Colors.white),)
                            ),
                          onPressed: () {
                            checkConnectivity().then((value) {
                              if(value){
                                if(nameController.text!="" && passwordController.text!=""){
                                  checkForLogin(nameController.text, passwordController.text, context);
                                  nameController.clear();
                                  passwordController.clear();
                                }else if(nameController.text=="" || passwordController.text==""){
                                  Fluttertoast.showToast(
                                    msg: "Fill Empty Fields",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1
                                  );
                                } 
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
                          )
                        ),
                      ),
                      SizedBox(height: 10,),
                      FadeAnimation(2.0,Center(
                        child:InkWell(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: RichText(
                              text: TextSpan(
                              text: strings["signUpLinkText"], style: TextStyle(color: Colors.black, fontSize: 17),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' Sign up', 
                                  style: TextStyle(color: Colors.orange[900], fontSize: 17),
                                  recognizer: TapGestureRecognizer()
                                  ..onTap=(){
                                    Navigator.push(context,MaterialPageRoute(builder:(context)=>PhoneSignPage()));
                                  }
                                )
                              ]),
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
      )
    );

  }
}