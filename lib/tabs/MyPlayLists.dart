

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/components/mySnackbar.dart';
import 'package:trax_xone/models/PlayListData.dart';

class MyPlayLists extends StatefulWidget {
  const MyPlayLists({Key? key}) : super(key: key);

  @override
  State<MyPlayLists> createState() => _MyPlayListsState();
}

class _MyPlayListsState extends State<MyPlayLists> {

  List<PlayListData> playList = [];
  late final String myId;
  var playListName = new TextEditingController();

  bool isListReady = false;
  List<String> songList = [""];


  getPlaylistsDocs() async{
    playList.clear();

    if(!isListReady) {
      myId = await FirebaseAuth.instance.currentUser!.uid.toString();
    }

    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('MyPlayLists').doc(myId).collection("Lists").get();
    querySnapshot.docs.forEach((doc) {
      PlayListData playListData = PlayListData.fromMap(doc.data() as Map<String, dynamic>);

      playList.add(playListData);
    });
    playList.add(PlayListData(playListId: "newList", playListName: "", currentSongId: "", numberofSong: 0, timestamp: 0.0, songlist: songList));
    isListReady = true;
    setState(() {

    });

    print(playList.length.toString());
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPlaylistsDocs();

  }




  showCreateDialoge(BuildContext context){
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 32),
            color: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: Colors.grey.shade700,
                    width: 2.5
                )
            ),
            child: Container(
              color: Colors.black26,
              height: 240,
              width: MediaQuery.of(context).size.width-100,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Text(
                    "Playlist name",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 20,),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Enter playlist name",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: "Reform",
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(height: 12,),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: playListName,
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


                      ),
                    ),
                  ),
                  SizedBox(height:36),
                  ElevatedButton(
                      onPressed: () async{
                        MyProgress().showLoaderDialog(context);
                        String listName = playListName.text.toString().trim();
                        if(listName.length>0){
                          double timestamp = Timestamp.now().seconds.toDouble();

                          String? playListId = await FirebaseDatabase.instance.reference().push().key;
                          PlayListData listData = PlayListData(playListId: playListId!, playListName: listName, currentSongId: "", numberofSong: 0, timestamp: timestamp, songlist: songList);

                          Map<String,dynamic> playList = listData.toPlayListMap();
                          CollectionReference playListRef = FirebaseFirestore.instance
                              .collection("MyPlayLists").doc(myId).collection("Lists");
                          playListRef.doc(playListId).set(playList).whenComplete(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            MySnackBar().showSnackbar(context, "PlayList successfully created!");
                            getPlaylistsDocs();
                            playListName.text = "";
                            setState(() {

                            });
                            Navigator.pushNamed(context, '/search',arguments: {
                              "listId": playListId
                            });
                          });
                        }
                        else{
                          Navigator.pop(context);
                          MySnackBar().showSnackbar(context, "Playlist name required!");
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
                        width: 140,
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
                          "Create Play List",
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
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: isListReady  ? SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            children: [

              //my play list text layout...
              SizedBox(height: 12,),

              //pre added songs play list cards...
              Wrap(
                children: playList.map((e) {
                  return Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        color: Colors.black54,
                        child: InkWell(
                          onTap: (){
                            if(e.playListId=="newList") {
                              showCreateDialoge(context);
                            }
                            else{
                              if(e.numberofSong==0){
                                Navigator.pushNamed(context, '/search',arguments: {
                                  "listId": e.playListId
                                });
                              }
                              else{
                                Navigator.pushNamed(context, '/viewPlaylist',arguments: {
                                  "listId": e.playListId
                                });
                              }
                            }
                          },
                          child: new Container(
                            padding: EdgeInsets.only(left:12,right: 12, top: 12, bottom: 24),
                            width: (MediaQuery.of(context).size.width/2)-28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              children: [
                                // Align(
                                //   child: Text(
                                //     e.numberofSong%2==0?"Online":"",
                                //     style: TextStyle(
                                //       color: Colors.red.shade900,
                                //       fontSize: 12,
                                //       fontFamily: "Reform",
                                //       fontWeight: FontWeight.bold
                                //     ),
                                //   ),
                                //   alignment: Alignment.topLeft,
                                // ),
                                SizedBox(height: 24,),
                                Image(
                                  image: AssetImage(e.playListId=="newList" ? 'assets/icons/create_playlist_icon.png' : 'assets/icons/urdu_song.png'),
                                  height: 80,
                                ),
                                SizedBox(
                                  height: e.playListId=="newList" ?24 :12,
                                ),

                                e.playListId=="newList" ? Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Create Playlist",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Reform",
                                        fontSize: 14
                                    ),
                                  ),
                                ) : Container(
                                    width: MediaQuery.of(context).size.width/2-36,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.playListName,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Reform",
                                                  fontSize: 14
                                              ),
                                            ),
                                            SizedBox(height: 4,),
                                            Text(
                                              e.numberofSong.toString()+" songs",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Reform",
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(child: Container()),
                                        IconButton(
                                          constraints: BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          onPressed: () async{
                                            MyProgress().showLoaderDialog(context);
                                            await FirebaseFirestore.instance.collection("MyPlayLists").doc(myId)
                                                .collection("Lists").doc(e.playListId).delete().whenComplete(() {
                                                  getPlaylistsDocs();
                                                  MySnackBar().showSnackbar(context, "PlayList successfully removed!");
                                                  Navigator.pop(context);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red.shade900,
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ) : Center(
        child: SpinKitSpinningLines(
          color: Colors.red.shade900,
          size: 80,
          lineWidth: 3,
        ),
      ),
    );




  }
}
