
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/components/mySnackbar.dart';
import 'package:trax_xone/models/MusicCardData.dart';
import 'package:trax_xone/models/SongsData.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({Key? key}) : super(key: key);

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {

  List<MusicCardModel> imageList =[
    MusicCardModel(cardImage: 'assets/icons/urdu_song.png', cardText: "English Songs"),
    MusicCardModel(cardImage: 'assets/icons/urdu_song.png', cardText: "Hindi Songs"),
    MusicCardModel(cardImage: 'assets/icons/urdu_song.png', cardText: "Arabic Songs"),
    MusicCardModel(cardImage: 'assets/icons/urdu_song.png', cardText: "Urdu Songs"),
  ];

  var placeHolderImg = AssetImage('assets/backgrounds/profile_pic.jpg');
  String profilePicUrl = "";
  String? username;
  late SongsData songsData = SongsData(songId: "", songName: "", songArtist: "", songCoverUrl: "", songUrl: "", songType: "", songViews: 0, timestamp: 0, userId: "", isFav: false);

  late DocumentSnapshot firstDocument;

  var audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;
  String songDuration = "";
  int limit = 1;
  bool limitUpdated = false;
  bool isSongReady = false;
  bool isProgressVisible = false;


  //getting user id of current user...
  String uId = FirebaseAuth.instance.currentUser!.uid.toString();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getFirstSong(limit);

    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    users.doc(uId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Access the document data
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;

        // Perform actions with the data

        setState(() {
          username = data!['Username'];
          profilePicUrl = data['ProfilePic'];
        });
      } else {
        print('Document does not exist');
      }
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;

    });

  }


  getFirstSong(int limit)async{

    if (limitUpdated){
      MyProgress().showLoaderDialog(context);
    }

    await FirebaseFirestore.instance.collection('Songs').orderBy("Timestamp",descending: true).limit(limit).get().then((snapshot) async{

      if(snapshot.docs.isNotEmpty){
        firstDocument = await snapshot.docs.last;
        songsData = await SongsData.fromMap(firstDocument.data() as Map<String, dynamic>);
      }

    });

    isSongReady = true;
    getSongDuration();
    setState(() {

    });

  }

  stopSong(){
    audioPlayer.stop();
    isPlaying = false;
    setState(() {

    });
  }

  playSong()async{
    MyProgress().showLoaderDialog(context);
    await audioPlayer.play(UrlSource(songsData.songUrl));
    Navigator.pop(context);

    if(!isPlaying){
      print("Hellow Player");
      await audioPlayer.resume();
      isPlaying = true;

    }else{
      await audioPlayer.pause();
      isPlaying = false;
    }

    setState(() {

    });
  }

  getSongDuration() async{


    await audioPlayer.play(UrlSource(songsData.songUrl));
    await audioPlayer.pause();

    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    songDuration = minutes.toString() + ":" + seconds.toString() + " min";

    if(limitUpdated){
      Navigator.pop(context);
    }
    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    audioPlayer.onPlayerComplete.listen((event) {
      audioPlayer.stop();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(251, 0, 91, 1),
        ),
        actions: [
          IconButton(
            onPressed: (){
              stopSong();
              Navigator.pushNamed(context, '/search',arguments: {
                "type": "all"
              });
            },
            icon: Icon(
              Icons.search,
              color: Color.fromRGBO(251, 0, 91, 1),
            ),
          )
        ],

      ),

      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(height: 24,),
                //profile pic...
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(blurRadius: 1, color: Colors.red.shade900,spreadRadius: 3)]
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: profilePicUrl.length<1? placeHolderImg:NetworkImage(profilePicUrl) as ImageProvider,
                    radius: 80,
                  ),
                ),
                SizedBox(height: 36,),

                //username...
                Row(
                  children: [
                    Icon(
                      Icons.person_2_outlined,
                      color: Colors.grey,
                      size: 18,
                    ),
                    SizedBox(width: 6,),
                    Column(
                      children: [
                        Text(
                          username??"",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),
                        SizedBox(height: 8,)
                      ],
                    )
                  ],
                ),
                SizedBox(height: 6,),
                Container(
                  color: Colors.red.shade900,
                  height: 1,
                ),
                SizedBox(height: 10,),

                //edit profile button...
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/editProfile');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 6,),
                      Column(
                        children: [
                          Text(
                            "Edit Profile",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                          SizedBox(height: 8,)
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6,),
                Container(
                  color: Colors.red.shade900,
                  height: 1,
                ),
                SizedBox(height: 10,),

                // view Saved songs button...
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/mySaved');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.save_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 6,),
                      Column(
                        children: [
                          Text(
                            "My Saved Songs",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                          SizedBox(height: 8,)
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 6,),
                Container(
                  color: Colors.red.shade900,
                  height: 1,
                ),
                SizedBox(height: 10,),


                // view privacy pollicy...
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/privacy');

                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 6,),
                      Column(
                        children: [
                          Text(
                            "Privacy Policy",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                          SizedBox(height: 8,)
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 6, ),
                Container(
                  color: Colors.red.shade900,
                  height: 1,
                ),
                SizedBox(height: 10, ),

                //help and feedback...
                InkWell(
                  onTap: (){
                    MySnackBar().showSnackbar(context, "This functionality is under development");
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 6,),
                      Column(
                        children: [
                          Text(
                            "Help & Feedback",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                          SizedBox(height: 8,)
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 18,),

                //log out button...
                InkWell(
                  onTap: ()async{
                    MyProgress().showLoaderDialog(context);
                    await FirebaseAuth.instance.signOut().whenComplete(() async{
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      await pref.setBool('isLogedIn', false);
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 6,),
                      Column(
                        children: [
                          Text(
                            "Log out",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                          SizedBox(height: 8,)
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //top songs text and buttons...
              Row(
                children: [
                  SizedBox(width: 16,),
                  Text(
                    "Songs",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24.0,
                      letterSpacing: 2,
                      fontFamily: "Reform",
                      fontWeight: FontWeight.w900,
                    )
                  ),
                  Expanded(child: Container()),
                  // previous song...
                  IconButton(
                    onPressed: (){
                      if(limit>1) {
                        --limit;
                        getFirstSong(limit);
                        setState(() {

                        });
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: limit>1 ? Colors.grey : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),

                  //play song...
                  IconButton(
                    onPressed: (){
                      isProgressVisible = !isProgressVisible;
                      playSong();
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),

                  //next song button...
                  IconButton(
                    onPressed: (){
                      limitUpdated = true;
                      ++limit;
                      getFirstSong(limit);
                      setState(() {
                        isPlaying = false;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              //new Song layout...
              isSongReady ? Container(
                height: 200,
                width: MediaQuery.of(context).size.width-32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade800,Colors.pink.shade600],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(4),
                  )
                ),
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Song",
                      style: TextStyle(
                        color: Colors.grey.shade50,
                        fontSize: 18,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      songsData.songName,
                      style: TextStyle(
                        color: Colors.grey.shade50,
                        fontSize: 24,
                        fontFamily: "Reform",
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Expanded(child: Container()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () async{
                            isProgressVisible = !isProgressVisible;
                            playSong();

                          },
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                            color: Colors.grey.shade50,
                          ),
                          iconSize: 60,
                        ),

                        isPlaying ? Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Visibility(
                              visible: isProgressVisible,
                              child: ProgressBar(
                                progress: Duration(seconds: position.inSeconds),
                                buffered: Duration(seconds: position.inSeconds+20),
                                total: Duration(seconds: duration.inSeconds),
                                thumbColor: Colors.grey.shade50,
                                baseBarColor: Colors.grey,
                                barHeight: 2,
                                bufferedBarColor: Colors.transparent,
                                timeLabelPadding: 12,
                                timeLabelTextStyle: TextStyle(
                                    color: Colors.grey.shade50,
                                    fontFamily: "Reform",
                                    fontWeight: FontWeight.bold
                                ),
                                thumbGlowRadius: 24,
                                progressBarColor: Colors.grey.shade50,
                                onSeek: (value)async{
                                  final position = value;
                                  await audioPlayer.seek(position);
                                },
                              ),
                            ),
                          ),
                        ) :Expanded(child: Container()),

                        isPlaying ? SizedBox(width: 6,) :
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.grey.shade50,
                              size: 20,
                            ),
                            SizedBox(width: 6,),
                            Text(
                              songDuration,
                              style: TextStyle(
                                color: Colors.grey.shade50,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),

                      ],
                    ),
                  ],
                ),
              ) :
              SpinKitSpinningLines(
                color: Colors.red.shade900,
                size: 120,
                lineWidth: 3,
              ),

              //music banner...
              Stack(
                alignment: Alignment.bottomCenter,
                children: [

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade900.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(
                        width: MediaQuery.of(context).size.width-24,
                        image: AssetImage('assets/backgrounds/music_banner.png'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8.0, bottom: 28),
                    alignment: Alignment.topLeft,
                    height: 150,
                    width: MediaQuery.of(context).size.width-24,
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage('assets/backgrounds/headphone.png'),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Listen your",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Reform',
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            SizedBox(height: 4,),
                            Text(
                              "favourite songs",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Reform',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 28,)
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16,),

              //see all songs layout...
              Row(
                children: [
                  SizedBox(width: 16,),
                  Text(
                      "Song Category",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        letterSpacing: 2,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.w900,
                      )
                  ),
                  Expanded(child: Container()),
                  InkWell(
                    onTap: (){
                      stopSong();
                      Navigator.pushNamed(context, '/search', arguments: {
                        "type":"all"
                      });
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 14.0,
                        letterSpacing: 2,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(width: 16,)
                ],
              ),
              SizedBox(height: 4,),

              //songs category cards...
              Wrap(
                children: imageList.map((e) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  color: Colors.black54,
                  child: InkWell(
                    onTap: (){
                      stopSong();
                      Navigator.pushNamed(context, '/search', arguments: {
                        "type": e.cardText.toString()
                      });
                    },
                    child: new Container(
                      padding: EdgeInsets.all(24),
                      height: 200,
                      width: (MediaQuery.of(context).size.width/2)-16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          Image(
                            image: AssetImage(e.cardImage),
                            height: 100,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            e.cardText,
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Reform',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 24,),

            ],
          ),
        ),
      ),



    );
  }
}
