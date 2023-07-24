
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/components/mySnackbar.dart';
import 'package:trax_xone/models/SongsData.dart';

import '../pages/EditSongPage.dart';


class AddSong extends StatefulWidget {
  const AddSong({Key? key}) : super(key: key);

  @override
  State<AddSong> createState() => _AddSongState();
}

class _AddSongState extends State<AddSong> {

  var placeHolder = AssetImage('assets/icons/urdu_song.png');
  var imagePading = EdgeInsets.all(24);
  var songNameEditor = TextEditingController();
  var songDescEditor = TextEditingController();
  var songArtistEditor = TextEditingController();

  File? coverPic;
  File? songFile;

  var songFilePath;

  var imagePicker = new ImagePicker();

  bool isSong = false;
  bool isCover = false;


  String songName = "";
  String songType = "English Song";
  String songDesc = "";
  String songArtist = "";
  int views = 0;
  int timestamp = 0;
  DateTime dateTime = DateTime.now();

  List songTypeList = [
    "English Song",
    "Hindi Songs",
    "Punjabi Songs",
    "Urdu Songs"
  ];
  bool isSongVisible = false;
  bool isSongSelectError = false;
  bool isSongNameError = false;
  bool isSongArtistError = false;
  bool isSongDescError = false;
  bool isSongUploadError = false;

  String trimmedSongFile = "";




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Scaffold(
        backgroundColor: Colors.grey.shade800,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //add songs text...
                Text(
                  "Add Song",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: "Reform",
                    fontSize: 24,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 28,),

                //select song layout...
                DottedBorder(
                  color: Colors.grey,
                  strokeWidth: 3,
                  dashPattern: [8,5],
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 120,
                    child: Row(
                      children: [
                        SizedBox(width: 30,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Select your song",
                               style: TextStyle(
                                 color: Colors.grey,
                                 fontFamily: 'Reform',
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                               ),
                            ),
                            SizedBox(height: 4,),
                            Text(
                              "from gallery(Mp3 file)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Reform',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12,),
                          ],
                        ),
                        SizedBox(width: 32,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: (){
                                setState(() {
                                  isCover = false;
                                  isSong = true;
                                  checkPermissions(isSong, isCover);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                minimumSize: Size(120, 24),
                                padding: EdgeInsets.all(0),
                              ),
                              child: Container(
                                width: 120,
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
                                  "Select Song",
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
                          ],
                        )
                      ],
                    ),
                  ),

                ),
                SizedBox(height: 4,),

                //song file selection error...
                Visibility(
                  visible: isSongSelectError,
                  child: Text(
                    "Song file Required",
                    style: TextStyle(
                        color: Colors.red.shade900,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(height: 12,),

                //sellected song layout...
                Visibility(
                  visible: isSongVisible,
                  child: Row(
                    children: [
                      //selected song play button...
                      IconButton(
                        onPressed: (){

                        },
                        icon: Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey,
                        ),
                        iconSize: 32,
                        padding: EdgeInsets.only(right: 6),
                        constraints: BoxConstraints(),
                      ),
                      //song name text...
                      Column(
                        children: [
                          Text(
                            songName,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Reform"
                            ),
                          ),
                          SizedBox(height: 4,)
                        ],
                      ),
                      Expanded(child: Container(),),
                      //Edit button Dot...
                      CircleAvatar(
                        backgroundColor: Colors.red.shade900,
                        radius: 6,
                      ),

                      //edit song button...
                      TextButton(
                        onPressed: () async{
                          trimmedSongFile = await Navigator.pushNamed(context, '/editSong', arguments: {
                            'songFile' : songFile?.path,
                          }) as String;
                          MySnackBar().showSnackbar(context, "Hello Trimmed File: " + trimmedSongFile);

                        },
                        // edit song button
                        child: Column(
                          children: [
                            Text(
                              "edit song",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Reform"
                              ),
                            ),
                            SizedBox(height: 6,)
                          ],
                        ),
                      ),

                      //remove selected song button...
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: (){
                          isSongVisible = false;
                          setState(() {
                            songName = "";
                            // songFile = null;
                            songFilePath = "";
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                      )

                    ],
                  )
                ),
                SizedBox(height: 12,),

                // songs details layout for uploading song...
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //profile cover...
                    // porfile pic...
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              child: coverPic==null? Image(
                                image: placeHolder,
                                height: 140,
                                width: 140,
                              ): Image.file(
                                coverPic!,
                                width: 140,
                                height: 140,
                              ),
                              width: 140,
                              height: 140,
                              padding: imagePading,
                              color: Colors.grey.shade900,
                            ),
                            Column(
                              children: [
                                TextButton(
                                  onPressed: (){
                                    checkPermissions(false, true);
                                  },
                                  child: Text(
                                    "Upload Cover",
                                    style: TextStyle(
                                      color: Colors.grey.shade50,

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
                    SizedBox(width: 12,),

                    // song details...
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2,),

                        // song name text field...
                        SizedBox(
                          height: 28,
                          width: 190,
                          child: TextField(
                            controller: songNameEditor,
                            cursorColor: Colors.red.shade900,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
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
                                  fontSize: 12,
                                  fontFamily: "Reform",
                              ),
                              hintText: "Song Name",
                            ),
                          ),
                        ),
                        //song name error...
                        Visibility(
                          visible: isSongNameError,
                          child: Text(
                            "Song name Required",
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),


                        // song artist text field...
                        SizedBox(
                          height: 28,
                          width: 190,
                          child: TextField(
                            controller: songArtistEditor,
                            cursorColor: Colors.red.shade900,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
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
                                fontSize: 12,
                                fontFamily: "Reform",
                              ),
                              hintText: "Song Artist",


                            ),
                          ),
                        ),
                        // Song Artist Error...
                        Visibility(
                          visible: isSongArtistError,
                          child: Text(
                            "Song Artist Required",
                            style: TextStyle(
                                color: Colors.red.shade900,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),

                        //song desc text field...
                        SizedBox(
                          width: 190,
                          child: TextField(
                            minLines: 3,
                            maxLines: 6,
                            controller: songDescEditor,
                            cursorColor: Colors.red.shade900,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
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
                              hintText: "Song Description",


                            ),
                          ),
                        ),
                        // song desc Error...
                        Visibility(
                          visible: isSongDescError,
                          child: Text(
                            "Song Description Required",
                            style: TextStyle(
                                color: Colors.red.shade900,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ),
                        SizedBox(height:24,)
                      ],
                    ),


                  ],
                ),


                //select song category layout...
                InputDecorator(
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(left: 12,right: 4),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8)
                    ),
                  ),
                  child: DropdownButton(
                    hint: Text("Select Song Type"),
                    dropdownColor: Colors.grey.shade900,
                    iconSize: 32,
                    iconEnabledColor: Colors.grey,
                    isExpanded: true,
                    isDense: true,
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: "Reform",
                      fontSize: 12,
                      fontWeight: FontWeight.bold,

                    ),
                    value: songType.isNotEmpty ? songType : null,
                    onChanged: (String? newValue){
                      setState(() {
                        songType = newValue.toString();
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: "English Song",
                        child: Text("English Songs"),
                      ),
                      DropdownMenuItem(
                        value: "Hindi Song",
                        child: Text("Hindi Songs"),
                      ),
                      DropdownMenuItem(
                        value: "Arabic Song",
                        child: Text("Arabic Songs"),
                      ),
                      DropdownMenuItem(
                        value: "Urdu Songs",
                        child: Text("Urdu Song"),
                      ),
                    ],

                  ),
                ),
                //song upload error...
                Visibility(
                  visible: isSongUploadError,
                  child: Text(
                    "No Internet! Please check your internet connection",
                    style: TextStyle(
                        color: Colors.red.shade900,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                    ),
                  ),
                ),
                SizedBox(height: 36,),

                // upload song layout...
                Center(
                  child: ElevatedButton(
                      onPressed: (){
                        songName = songNameEditor.text.toString().trim();
                        songArtist = songArtistEditor.text.toString().trim();
                        songDesc = songDescEditor.text.toString().trim();

                        if(songFile != null && songName.length>0 && songArtist.length>0 && songDesc.length>0){
                          uploadSong(songName, songArtist, songDesc);
                        }
                        else{
                          setState(() {

                            if(songFile==null){
                              isSongSelectError = true;
                            }
                            else{
                              isSongSelectError = false;
                            }

                            if(songName.length<1){
                              isSongNameError = true;
                            }
                            else{
                              isSongNameError = false;
                            }

                            if(songArtist.length<1){
                              isSongArtistError = true;
                            }
                            else{
                              isSongArtistError = false;
                            }

                            if(songDesc.length<1){
                              isSongDescError = true;
                            }
                            else{
                              isSongDescError = false;
                            }

                          });

                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: Size(120, 24),
                        padding: EdgeInsets.all(0),
                      ),
                      child: Container(
                        width: 120,
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
                          "Upload Song",
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
        ),
      ),

    );
  }


  void checkPermissions(bool isSong, bool isCover) async{
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if(statuses[Permission.storage]!.isGranted && statuses[Permission.camera]!.isGranted){
      print("Permission Granted");

      if(isSong){
        pickSong();
      }
      else if(isCover) {
        showImagePicker(context);
      }


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

  void pickSong() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if(result != null){
       PlatformFile file = await result.files.first;
       songFilePath = await file.path;
       songName = path.basename(songFilePath);
       setState(() {
         songNameEditor.text = songName.toString();
         isSong = true;
         isSongVisible = true;
       });
       songFile = await File(songFilePath)!;

    }

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
        imagePading = EdgeInsets.zero;
        coverPic = File(cropFile.path);
      });
    }

  }

  void uploadSong(String songName, String songArtist, String songDesc) async{
    MyProgress().showLoaderDialog(context);

    final DatabaseReference reference = FirebaseDatabase.instance.reference();
    final DatabaseReference newData = reference.push();
    String songId = newData.key!;
    String userId = await FirebaseAuth.instance.currentUser!.uid.toString();
    timestamp = dateTime.millisecondsSinceEpoch;
    songFile = await File(trimmedSongFile.length>1?trimmedSongFile : songFilePath)!;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage.ref().child("SongFiles").child("TraxXone"+songId);
    UploadTask uploadTask = storageRef.putFile(songFile!);
    await uploadTask.whenComplete(() async{
      print("Song uploaded successfully");

      await storageRef.getDownloadURL().then((songUrl) async{
        if(coverPic!=null){
          Reference imageRef = await storage.ref().child("SongCovers").child("TraxXone"+songId);
          UploadTask uploadImage = imageRef.putFile(coverPic!);
          await uploadImage.whenComplete(() async{
            await imageRef.getDownloadURL().then((coverImageUrl) async {
              SongsData songsData = SongsData(
                songId: songId!,
                songName: songName!,
                songArtist: songArtist,
                songCoverUrl: coverImageUrl!,
                songUrl: songUrl,
                songType: songType,
                songViews: views,
                timestamp: timestamp,
                userId: userId!,
                isFav: false,
              );

              CollectionReference firestore = await FirebaseFirestore.instance.collection("Songs");
              Map<String, dynamic> song = songsData.toSongsMap();
              await firestore.doc(songId).set(song).whenComplete(() {
                Navigator.pop(context);
                resetAddSong();
              });

            });
          });
        }
        else {
          SongsData songsData = SongsData(
            songId: songId!,
            songName: songName!,
            songArtist: songArtist,
            songCoverUrl: "",
            songUrl: songUrl,
            songType: songType,
            songViews: views,
            timestamp: timestamp,
            userId: userId!,
            isFav: false,
          );

          CollectionReference firestore = await FirebaseFirestore.instance.collection("Songs");
          Map<String, dynamic> song = songsData.toSongsMap();
          await firestore.doc(songId).set(song).whenComplete(() {
            Navigator.pop(context);
            resetAddSong();
          });
        }
      });
    }).onError((error, stackTrace) {

      setState(() {
        isSongUploadError = true;
      });
      return Future.error(error.toString());

    });

  }

  void resetAddSong (){
    setState(() {
      imagePading = EdgeInsets.all(24);
      songNameEditor.text = "";
      songArtistEditor.text = "";
      songDescEditor.text = "";
      songName = "";
      songFile = null;
      coverPic = null;
      isSongVisible = false;
      MySnackBar().showSnackbar(context, 'Song successfully uploaded');
    });
  }

}
