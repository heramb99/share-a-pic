
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharepic/Strings.dart';
import './NavDrawer.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import './models/ImageModel.dart';
import 'package:progress_dialog/progress_dialog.dart';

class HomePage extends StatefulWidget {

  final FirebaseUser user;

  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState(user:user);
}

class _HomePageState extends State<HomePage> {

  final FirebaseUser user;

  _HomePageState({this.user});

  TextEditingController hashTagController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("images");
  ProgressDialog progressDialog;

  Future pickAndUploadImage(String hashtag) async{

      final picker = ImagePicker();
      var pickedFile = await picker.getImage(source: ImageSource.gallery);
      File imageFile = File(pickedFile.path);
      
      progressDialog.show();
      String fileName = basename(pickedFile.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

      StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

      String url = (await downloadUrl.ref.getDownloadURL());

      var date = new DateTime.now().toString();
 
      var dateParse = DateTime.parse(date);
 
      var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
 

      ImageModel imageModel=ImageModel(fileName: fileName,hashTag: hashtag,date:formattedDate.toString(),userid: user.uid,url: url);

      dbRef.push().set(imageModel.toJson());

      progressDialog.hide();
      Fluttertoast.showToast(
        msg: "Images uploaded",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1
      );
          // setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    progressDialog.style(
      message: 'Uploading image...',
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
      drawer: NavDrawer(user: user,),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[900],
        onPressed: (){
          if(user.isEmailVerified){
            showDialog<String>(
            context: context,
            child: AlertDialog(
            title: Text('Post Image'),
              contentPadding: const EdgeInsets.all(16.0),
              content: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: hashTagController,
                      style: TextStyle(color:Colors.black),
                      autofocus: true,
                      decoration:InputDecoration(
                      hintText: Strings().hashtagHint),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Cancel',style: TextStyle(color:Colors.black),),
                  onPressed: () {
                    Navigator.pop(context);
                    hashTagController.clear();
                  }),
                  FlatButton( 
                    child: const Text('Select Image',style: TextStyle(color:Colors.black)),
                    onPressed: (){
                      if(hashTagController.text.trim()==""){
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Enter file name",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1
                        );
                      }else{
                        Navigator.pop(context);
                        pickAndUploadImage(hashTagController.text);            
                      } 
                      hashTagController.clear();
                    },
                  )
                ],
              ),
            ); 
          }else{
            showDialog(
              barrierDismissible: false,
              context: context,
              child:AlertDialog(
                title:Text('Alert'),
                content: Text('Verify your email to upload image.\nTo verify email check out your profile'),
                actions: <Widget>[
                  FlatButton(
                    onPressed:()async {
                      Navigator.pop(context);
                    }, 
                    child: Text('Ok')
                  ),
                ],
              )
            );
          }
          
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
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