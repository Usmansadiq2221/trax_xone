
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_seekbar/flutter_advanced_seekbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/components/MyTextStyle.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:trax_xone/components/mySnackbar.dart';
import 'package:trax_xone/models/FavSongData.dart';

import '../models/SongsData.dart';


class PlaySongPage extends StatefulWidget {
  const PlaySongPage({Key? key}) : super(key: key);

  @override
  State<PlaySongPage> createState() => _PlaySongPageState();
}

class _PlaySongPageState extends State<PlaySongPage> {

  Map data = {};

  late SongsData currentSong;

  List<SongsData> songList = [];
  int songIndex = 0;

  var favIcon = Icons.favorite_border;
  bool isFav = false;
  bool isPlaying = false;
  bool isListUpdated = false;
  bool isFirst = true;

  bool isQueue = true;
  bool isRandom = false;
  bool isRepeat = false;

  var preButtonColor = Colors.grey.shade100;

  var audioPlayer = AudioPlayer();
  final Random randomInt = new Random();
  final String? uId = FirebaseAuth.instance.currentUser?.uid;



  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  late PersistentBottomSheetController bottomSheetController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;

    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    super.dispose();
  }

  updateSong(int index){

    songIndex = songList.length==index ? 0 : index;
    currentSong = songList[songIndex] as SongsData;
    print(currentSong.songName + "is Fav? " +currentSong.isFav.toString());
    isFav = currentSong.isFav;
    audioPlayer.play(UrlSource(currentSong.songUrl));
    print("Completed");
    isListUpdated = true;
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {

    if(isFirst) {
      //getting data sent from previous page...
      data = data.isNotEmpty ? data : ModalRoute
          .of(context)
          ?.settings
          .arguments as Map;
      songList = data["songList"];
      songIndex = data["songIndex"];
      currentSong = songList[songIndex] as SongsData;
      isFirst = false;

    }
    preButtonColor = songIndex==0 ? Colors.grey : Colors.grey.shade100;
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
      if(!isListUpdated) {
        if(isQueue) {
          ++songIndex;
          updateSong(songIndex);
        }
        else if(isRandom){
          songIndex = randomInt.nextInt(songList.length);
          updateSong(songIndex);
        }
        else if(isRepeat){
          updateSong(songIndex);
        }
      }
    });


    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // dropdown arrow button...
        leading: ElevatedButton.icon(
          onPressed: (){
            showPlaylist(context);
            print("Hello arrow");

          },
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 32,
          ),
          label: Text(""),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.only(left: 6),
          ),
        ),
        actions: [
          //menu button...
          IconButton(
            onPressed: (){
              print("Hello Menu");
            },
            icon: Icon(
              Icons.more_vert
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero
            ),
          )
        ],
      ),
      // applying gradient...
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900,Color.fromRGBO(10, 10, 10, 1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24,),

                //cover image...
                ClipRRect(
                  child: Hero(
                    tag: "songCover",
                    child: Image(
                      image: NetworkImage(currentSong.songCoverUrl),
                      width: MediaQuery.of(context).size.width-64,
                      height: MediaQuery.of(context).size.width-64,
                      fit: BoxFit.fill,

                    ),
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),

                //Song name and and like button...
                Row(
                  children: [
                    // Song name & artist...
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 42,),
                        Text(
                          currentSong.songName,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Reform",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),

                        ),
                        SizedBox(height: 8,),
                        Text(
                          currentSong.songArtist,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Reform",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),

                    // fav button...
                    Column(
                      children: [
                        SizedBox(height: 32,),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isFav = !isFav;
                              MyProgress().showLoaderDialog(context);

                              CollectionReference userCollection = FirebaseFirestore.instance.collection("Songs");
                              DocumentReference documentReference = userCollection.doc(currentSong.songId);

                              DocumentReference favSongRef = FirebaseFirestore.instance.collection("FavSongs").doc(uId!).collection("Songs").doc(currentSong.songId);
                              if(isFav){
                                documentReference.update({'isFav': true}).whenComplete(() {
                                  FavSongData favSongData = FavSongData(songId: currentSong.songId);
                                  Map<String, dynamic> favSong = favSongData.toFavSongMap();
                                  favSongRef.set(favSong).whenComplete(() {
                                    Navigator.pop(context);
                                  });

                                }).onError((error, stackTrace) {
                                  MySnackBar().showSnackbar(context, 'Network Problem! Please check your interne connection');
                                });
                              }
                              else{
                                documentReference.update({'isFav': false}).whenComplete(() {

                                  favSongRef.delete().whenComplete(() {
                                    Navigator.pop(context);
                                  });

                                }).onError((error, stackTrace) {
                                  MySnackBar().showSnackbar(context, 'Network Problem! Please check your interne connection');
                                });

                              }
                            });
                          },
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                SizedBox(height: 42,),


                
                ProgressBar(
                  progress: Duration(seconds: position.inSeconds),
                  buffered: Duration(seconds: position.inSeconds+20),
                  total: Duration(seconds: duration.inSeconds),
                  thumbColor: Colors.red.shade900,
                  baseBarColor: Colors.grey,
                  barHeight: 2,
                  bufferedBarColor: Colors.transparent,
                  timeLabelPadding: 12,
                  timeLabelTextStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: "Reform",
                    fontWeight: FontWeight.bold
                  ),
                  thumbGlowRadius: 24,
                  progressBarColor: Colors.red.shade900,
                  onSeek: (value)async{
                    final position = value;
                    await audioPlayer.seek(position);
                    isListUpdated = false;
                  },


                ),



                SizedBox(height: 64,),

                // controller layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    //change repeat button...
                    Container(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (){
                          setState(() {
                            if(isQueue){
                              isQueue = false;
                              isRandom = true;
                            }
                            else if(isRandom){
                              isRandom = false;
                              isRepeat = true;
                            }
                            else if(isRepeat){
                              isRepeat = false;
                              isQueue = true;
                            }
                          });
                        },
                        child: Icon(
                          isQueue ? Icons.repeat : isRandom ? Icons.shuffle:Icons.repeat_one,
                          color: Colors.grey.shade100,
                          size: 26,
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)
                            )
                        ),

                      ),
                    ),
                    SizedBox(width: 24,),

                    // previous button...
                    Container(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (){
                          if(songIndex>0){
                            --songIndex;
                            updateSong(songIndex);
                            if(songIndex==0){
                              preButtonColor = Colors.grey;
                            }
                          }



                        },
                        child: Icon(
                          Icons.skip_previous,
                          color: preButtonColor,
                          size: 26,
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)
                            )
                        ),

                      ),
                    ),
                    SizedBox(width: 32,),

                    //play song Button...
                    Container(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: ()async{
                          MyProgress().showLoaderDialog(context);
                          await audioPlayer.play(UrlSource(currentSong.songUrl));
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

                        },
                        child: Icon(
                          isPlaying? Icons.pause : Icons.play_arrow,
                          color: Colors.grey.shade100,
                          size: 36,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                          )
                        ),

                      ),
                    ),
                    SizedBox(width: 32,),

                    //forward button...
                    Container(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (){
                          ++songIndex;
                          updateSong(songIndex);
                        },
                        child: Icon(
                          Icons.skip_next,
                          color: Colors.grey.shade100,
                          size: 26,
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)
                            )
                        ),

                      ),
                    ),
                    SizedBox(width: 24,),

                    //play list...
                    Container(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (){
                          showPlaylist(context);
                        },
                        child: Icon(
                          Icons.queue_music,
                          color: Colors.grey.shade100,
                          size: 26,
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)
                            )
                        ),

                      ),
                    ),
                  ],
                ),





              ],

            ),
          ),
        ),
      ),
    );
  }


  void showPlaylist(BuildContext context) async{

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder){
          return StatefulBuilder(
            builder: (BuildContext context,StateSetter setState){
              return ClipRRect(
                child: Card(
                  elevation: 12,
                  color: Color.fromRGBO(20, 20, 20, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(35.0), topRight: Radius.circular(35.0))
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 4),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/1.5,
                    child: ListView.builder(
                      itemCount: songList.length,
                      itemBuilder: (BuildContext context, int index) {
                        SongsData songsdata = songList[index];
                        return Container(
                          color: currentSong.songId == songsdata.songId ? Colors.grey.shade900 : Colors.transparent,
                          child: ListTile(
                            onTap: (){
                              setState((){
                                updateSong(index);
                              });
                            },
                            contentPadding: EdgeInsets.only(top:4, bottom: 4, left: 16, right: 4),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                songsdata.songCoverUrl,
                              ),
                              radius: 24,
                            ),
                            title: Text(
                              songsdata.songName,
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              songsdata.songArtist,
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              constraints: BoxConstraints(),
                              onPressed: (){
                                setState((){
                                  SongsData removedData = songList[index];
                                  if(currentSong.songId == removedData.songId) {
                                    updateSong(index + 1);
                                  }
                                  songList.removeAt(index);



                                });
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              iconSize: 28,
                            ),

                          ),
                        );
                      },
                    ),

                  ),
                ),
              );

            }
          );
        }
    );
  }

}
