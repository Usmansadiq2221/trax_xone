import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/models/Userdata.dart';
import 'package:firebase_storage/firebase_storage.dart';


class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({Key? key}) : super(key: key);

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {

  var placeHolder = AssetImage('assets/icons/cam.png');
  var profilePadding = EdgeInsets.all(56);
  var imageColor = Colors.grey;
  File? profilePic;

  var _username = TextEditingController();
  var _phone = TextEditingController();
  var _desc = TextEditingController();
  String permissionError = "";
  bool isPermitError = false;
  var imagePicker = ImagePicker();

  bool isUserNameError = false;
  bool isPhoneError = false;
  bool isDescError = false;
  bool isNetworkrror = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.pink.shade900, Colors.pink.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            ),
            child: Column(
              children: [

                SizedBox(height: 12,),
                Text(
                  "Create Profile",
                  style: TextStyle(
                    color: Colors.grey.shade100,
                    fontFamily: "Reform",
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                ),
                SizedBox(height: 36,),

                Stack(
                  children: [

                    Column(
                      children: [
                        SizedBox(height: 85,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height-155,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(20, 20, 20, 1),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38, spreadRadius: 5)]
                          ),
                        ),
                      ],
                    ),

                    // details input layout...
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          //profile picture...
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    child: profilePic==null? Image(
                                      image: placeHolder,
                                      height: 50,
                                      width: 50,
                                      color: imageColor,
                                    ): Image.file(
                                      profilePic!,
                                      width: 140,
                                      height: 140,
                                    ),
                                    width: 140,
                                    height: 140,
                                    padding: profilePadding,
                                    color: Colors.grey.shade900,
                                  ),

                                  //upload picture button...
                                  Column(
                                    children: [
                                      TextButton(
                                        onPressed: (){
                                          checkPermissions();
                                        },
                                        child: Text(
                                          "Upload Picture",
                                          style: TextStyle(
                                            color: Colors.grey.shade200,
                                            fontFamily: "Reform",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          minimumSize: Size(140, 36),
                                          backgroundColor: Colors.grey.shade50.withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0)
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12,)
                                    ],
                                  ),
                                ]
                            ),
                          ),
                          SizedBox(height: 24,),

                          //username field...
                          SizedBox(
                            height: 42,
                            width: MediaQuery.of(context).size.width-64,
                            child: TextField(
                              controller: _username,
                              cursorColor: Colors.red.shade900,
                              keyboardType: TextInputType.name,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_2_outlined,
                                ),
                                prefixIconColor: Colors.grey,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: -5),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade900, width: 2.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),

                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontFamily: "Reform",
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Username?",
                              ),
                            ),
                          ),
                          //username error text...
                          Visibility(
                            visible: isUserNameError,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 2, left: 36),
                              child: Text(
                                "Username Required!",
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 14,
                                  fontFamily: "Reform",
                                  fontWeight: FontWeight.bold
                                ),

                              ),
                            ),
                          ),
                          SizedBox(height: 16,),

                          //phone number field...
                          SizedBox(
                            height: 42,
                            width: MediaQuery.of(context).size.width-64,
                            child: TextField(
                              controller: _phone,
                              cursorColor: Colors.red.shade900,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                ),
                                prefixIconColor: Colors.grey,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: -5),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade900, width: 2.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),

                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontFamily: "Reform",
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "Phone Number?",
                              ),
                            ),
                          ),

                          //phone no error text...
                          Visibility(
                            visible: isPhoneError,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 2, left: 36),
                              child: Text(
                                "Phone Number Required!",
                                style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 14,
                                    fontFamily: "Reform",
                                    fontWeight: FontWeight.bold
                                ),

                              ),
                            ),
                          ),
                          SizedBox(height: 16,),

                          //description field...
                          SizedBox(
                            width: MediaQuery.of(context).size.width-64,
                            child: TextField(
                              minLines: 6,
                              maxLines: 8,
                              controller: _desc,
                              cursorColor: Colors.red.shade900,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontFamily: "Reform",
                                  fontWeight: FontWeight.bold
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade900, width: 2.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),

                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: "Reform",
                                ),
                                hintText: "User Description",


                              ),
                            ),
                          ),
                          //desc error text...
                          Visibility(
                            visible: isDescError,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 2, left: 36),
                              child: Text(
                                "User description Required!",
                                style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 14,
                                    fontFamily: "Reform",
                                    fontWeight: FontWeight.bold
                                ),

                              ),
                            ),
                          ),

                          //internet error text...
                          Visibility(
                            visible: isNetworkrror,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 2, left: 36, right: 36),
                              child: Text(
                                "Request Failed! Make sure you have an internet connection",
                                style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 14,
                                    fontFamily: "Reform",
                                    fontWeight: FontWeight.bold
                                ),

                              ),
                            ),
                          ),
                          SizedBox(height: 40,),

                          // details sumit button...
                          Center(
                            child: ElevatedButton(
                                onPressed: (){
                                  createProfile();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  minimumSize: Size(150, 24),
                                  padding: EdgeInsets.all(0),
                                ),
                                child: Container(
                                  width: 150,
                                  height: 28,
                                  padding: EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.red.shade600, Colors.red.shade900],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Create Profile",
                                    style: TextStyle(
                                      color: Colors.grey.shade50,
                                      fontFamily: 'Reform',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                            ),
                          ),


                        ],

                      ),
                    ),


                  ],
                )
                
                

              ],
            ),
          ),
        ),
      ),
    );
  }


  void createProfile() async {
    MyProgress().showLoaderDialog(context);
    String username = _username.text.toString().trim();
    String phoneNo = _phone.text.toString().trim();
    String desc = _desc.text.toString().trim();

    var user = await FirebaseAuth.instance.currentUser;
    String? email = await user!.email;
    String? uId = await user!.uid;
    String? profileUrl = "";


    if(username.length>0 && phoneNo.length>0 && desc.length>0){

      setState(() {
        isUserNameError = false;
        isPhoneError = false;
        isDescError = false;
        isNetworkrror = false;
      });

      //UPLOAD PROFILE PIC TO STORAGE...
      if(profilePic!=null){

        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref().child("ProfilePics").child(uId+"profilePic");
        UploadTask uploadTask = storageRef.putFile(profilePic!);

        await uploadTask.whenComplete(() {
          // Image upload complete
          print('Image uploaded successfully.');

          // Retrieve the download URL for the uploaded image
          storageRef.getDownloadURL().then((imageUrl) {
            // upload data to firestore doc...
            try {
              final CollectionReference usersCollection =
              FirebaseFirestore.instance.collection('Users');

              Userdata userdata = Userdata(uId: uId,
                  username: username,
                  email: email!,
                  phoneNo: phoneNo,
                  desc: desc,
                  profileUrl: imageUrl);
              Map<String, dynamic> user = userdata.toUserMap();
              usersCollection.doc(uId).set(user).whenComplete(() async {
                Navigator.pop(context);
                SharedPreferences preferences = await SharedPreferences
                    .getInstance();
                await preferences.setBool("isProfileCreated", true);
                Navigator.popAndPushNamed(context, '/home');
              });
            } catch(e){
              print(e.toString());
              Navigator.pop(context);

            }

          });
        });


      }else{
        try {
          final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

          Userdata userdata = Userdata(uId: uId,
              username: username,
              email: email!,
              phoneNo: phoneNo,
              desc: desc,
              profileUrl: profileUrl);
          Map<String, dynamic> user = userdata.toUserMap();
          usersCollection.doc(uId).set(user).whenComplete(() async {
            Navigator.pop(context);
            SharedPreferences preferences = await SharedPreferences
                .getInstance();
            await preferences.setBool("isProfileCreated", true);
            Navigator.popAndPushNamed(context, '/home');
          });
        } catch(e){
          print(e.toString());
          Navigator.pop(context);
          setState(() {
            isNetworkrror = true;
          });
        }
      }

    }else{

      Navigator.pop(context);

      setState(() {
        if(username.length<1){
          isUserNameError = true;
        }else{
          isUserNameError = false;
        }

        if(phoneNo.length<1){
          isPhoneError = true;
        }else{
          isPhoneError = false;
        }

        if(desc.length<1){
          isDescError = true;
        }else{
          isDescError = false;
        }
      });


    }

  }

  void checkPermissions() async{
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if(statuses[Permission.storage]!.isGranted && statuses[Permission.camera]!.isGranted){
      print("Permission Granted");
      showImagePicker(context);


    }
    else{
      if(statuses[Permission.storage]!.isDenied || statuses[Permission.camera]!.isDenied){
        statuses = await [
          Permission.camera,
          Permission.storage,
        ].request();
      }
      if(statuses[Permission.storage]!.isPermanentlyDenied || statuses[Permission.camera]!.isPermanentlyDenied){
        openAppSettings();
      }
      print("permission not granted");
    }

  }
  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.grey.shade900,
        context: context,
        builder: (builder){
          return Card(
            color: Colors.grey.shade900,
            child: Container(

              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/5.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //pick image from gallery...
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        pickImageFromGallery();
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          Icon(
                            Icons.image,
                            size: 90,
                            color: Colors.grey,
                          ),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  //pick image from camera...
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        pickImageFromCamera();
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          Icon(
                            Icons.camera,
                            size: 90,
                            color: Colors.grey,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        }
    );
  }

  void pickImageFromGallery() async{
    await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    ).then((value) {
      if(value!=null){
        cropImage(File(value.path));
      }
    });

    print("Picked from Gallery");

  }


  void pickImageFromCamera() async{

    await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    ).then((value){
      if(value!=null){
        cropImage(File(value.path));
      }
    });

    print("Picked from Camera");

  }

  void cropImage(File imgFile) async{
    var cropFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [AndroidUiSettings(
            toolbarTitle: "Image Cropper",
            toolbarColor: Colors.red.shade900,
            toolbarWidgetColor: Colors.grey.shade100
        ),
          IOSUiSettings(
            title: "Image Cropper",
          )
        ]);
    if(cropFile != null){
      imageCache.clear();
      setState(() {
        profilePadding = EdgeInsets.all(0);
        profilePic = File(cropFile.path);
      });
    }

  }



}
