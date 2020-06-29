
import 'dart:async';
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
import 'package:photo_view/photo_view.dart';

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
  TextEditingController nameController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("images");
  ProgressDialog progressDialog;
  List imageList=List();
  StreamSubscription subscription;

  //fetch newly uploaded image using subscription
  void imageAddedSubscription(Event event){
    setState(() {});
  }

  Future pickAndUploadImage(String hashtag,String name) async{

      //picking image from gallery
      final picker = ImagePicker();
      var pickedFile = await picker.getImage(source: ImageSource.gallery);
      File imageFile = File(pickedFile.path);
      
      progressDialog.show();

      //uploading image to firebase storage
      String fileName = basename(pickedFile.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      String url = (await downloadUrl.ref.getDownloadURL());

      //getting current date
      var date = new DateTime.now().toString();
      var dateParse = DateTime.parse(date);
      var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
 
      //uploading image info to database
      ImageModel imageModel=ImageModel(fileName: name,hashTag: hashtag,date:formattedDate.toString(),userid: user.uid,url: url);
      dbRef.push().set(imageModel.toJson());

      progressDialog.hide();
      Fluttertoast.showToast(
        msg: "Images uploaded",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1
      );
  }
  @override
  void initState() {
    super.initState();
    subscription = dbRef.onChildAdded.listen(imageAddedSubscription);

  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    style: TextStyle(color:Colors.black),
                    autofocus: true,
                    decoration:InputDecoration(
                    hintText: Strings().nameHint),
                  ),
                  TextField(
                    controller: hashTagController,
                    style: TextStyle(color:Colors.black),
                    autofocus: true,
                    decoration:InputDecoration(
                    hintText: Strings().hashtagHint),
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
                      if(hashTagController.text.trim()=="" || nameController.text.trim()==""){
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Fill empty fields",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1
                        );
                      }else if(hashTagController.text.length>32 || nameController.text.length>32){
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Only 32 characters are allowed",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1
                        );
                      }else{
                        Navigator.pop(context);
                        pickAndUploadImage(hashTagController.text,nameController.text);            
                      } 
                      hashTagController.clear();
                      nameController.clear();
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
        padding: EdgeInsets.all(12),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[ 
            SizedBox(height: 16,),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child:FutureBuilder(
                          future: dbRef.once(),
                          builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
                            if (snapshot.connectionState == ConnectionState.waiting){
                              return Container(
                                child: Center(
                                  child : CircularProgressIndicator()
                                ),
                              );
                            }else if(snapshot.hasData){
                              imageList.clear();
                              Map<dynamic, dynamic> values = snapshot.data.value;
                              if(values==null){
                                return Center(
                                  child: Text(Strings().zeroImages,style: TextStyle(color:Colors.black,fontSize: 18),),
                                );
                              }else{
                                values.forEach((key, values) {
                                  imageList.add(values);
                                });
                                return ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: imageList.length,
                                  itemBuilder: (BuildContext context, int index){
                                    return Container(
                                      height: 400,
                                      child: Card(
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(imageList[index]["filename"],style: TextStyle(color:Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                                              SizedBox(height: 5,),
                                              Text(imageList[index]["hashtag"],style: TextStyle(color:Colors.blue,fontSize: 16),),
                                              SizedBox(height: 5,),
                                              Expanded(
                                                child: ClipRect(
                                                  child:PhotoView(
                                                    imageProvider: NetworkImage(imageList[index]["url"])
                                                  )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text("Posted on:"+imageList[index]["date"],style: TextStyle(color:Colors.black,fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                );
                              }
                            }
                          }
                        )
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}