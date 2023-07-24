
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/models/FavSongData.dart';
import 'package:trax_xone/models/SongsData.dart';

class MySavedSongs extends StatefulWidget {
  const MySavedSongs({Key? key}) : super(key: key);

  @override
  State<MySavedSongs> createState() => _MySavedSongsState();
}

class _MySavedSongsState extends State<MySavedSongs> {

  late final String myId;
  late String playlistName = "";
  String playlistId = "";
  bool isIdInit = false;
  List<String> songsIdList = <String>[];
  List<SongsData> songsList = <SongsData>[];
  bool isListReady = false;
  var snapshot;
  var favSongRef;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getFavSongsIds();

  }

  getFavSongsIds() async{
    songsIdList.clear();
    if(!isIdInit) {
      myId = await FirebaseAuth.instance.currentUser!.uid.toString();
      isIdInit = true;
    }

    favSongRef = await FirebaseFirestore.instance.collection("FavSongs").doc(myId).collection('Songs');
    QuerySnapshot querySnapshot = await favSongRef.get();
    // await FirebaseFirestore.instance.collection("FavSongs").doc(myId).collection('Songs').get();
    querySnapshot.docs.forEach((doc) {
      FavSongData favSongData = FavSongData.fromMap(doc.data() as Map<String, dynamic>);
      songsIdList.add(favSongData.songId);
    });

    getSongsData(songsIdList);
  }

  getSongsData(List<String> songsIdList)async{

    print("No of fav songs: " + songsIdList.length.toString());
    songsList.clear();

    for(String songId in songsIdList){

      var songREf = await FirebaseFirestore.instance.collection("Songs").doc(songId).get();
      SongsData songsData = await SongsData.fromMap(songREf.data() as Map<String, dynamic>);
      songsList.add(songsData);

    }


    isListReady = true;
    setState(() {

    });

    print("Songs List length : " + songsList.length.toString());

  }




  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 12,
        iconTheme: IconThemeData(
            color: Colors.grey,
            size: 28
        ),
        title: Text(
          "My Saved Songs",
          style: TextStyle(
              fontFamily: "Reform",
              color: Colors.grey,
              fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, '/search', arguments: {
                "listId": playlistId
              });
            },
            icon: Icon(
                Icons.add_circle_outline
            ),
          )
        ],
      ),

      body: Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: isListReady ? ListView.builder(
            itemCount: songsList.length,
            itemBuilder: (context, index) {

              SongsData song= songsList[index] as SongsData;
              bool isAdded = false;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 4,),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      color: Colors.grey.shade900,
                      elevation: 6,
                      child: ListTile(
                        onTap: (){

                          Navigator.pushNamed(context, '/playSong',arguments: {
                            'songIndex' : index,
                            'songList' : songsList
                          });
                        },
                        contentPadding: EdgeInsets.only(top:8, bottom: 8, left: 12, right: 4),
                        leading: Hero(
                          tag: "songCover",
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              song.songCoverUrl,
                            ),
                            radius: 24,
                          ),
                        ),
                        title: Text(
                          song.songName,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Reform",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          song.songArtist,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Reform",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Visibility(
                          visible: !isAdded,
                          child: IconButton(
                            constraints: BoxConstraints(),
                            onPressed: ()async{
                              MyProgress().showLoaderDialog(context);
                              await FirebaseFirestore.instance.collection("FavSongs").doc(myId).collection('Songs').doc(song.songId).delete().whenComplete((){
                                getFavSongsIds();
                              });
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.grey,
                            ),
                            iconSize: 28,
                          ),
                        ),

                      ),
                    ),
                  ],
                ),
              );


            }
        ) : SpinKitSpinningLines(
          lineWidth: 3,
          color: Colors.red.shade900,
          size: 100,
        ),
      ),
    );
  }
}
