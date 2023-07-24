
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/components/mySnackbar.dart';
import 'package:trax_xone/models/PlayListData.dart';
import 'package:trax_xone/models/SongsData.dart';

class ViewPlaylist extends StatefulWidget {
  const ViewPlaylist({Key? key}) : super(key: key);

  @override
  State<ViewPlaylist> createState() => _ViewPlaylistState();
}

class _ViewPlaylistState extends State<ViewPlaylist> {

  Map data = {};
  late final String myId;
  late String playlistName = "";
  String playlistId = "";
  bool isIdInit = false;
  late PlayListData playlistData;
  List<String> songsIdList = <String>[];
  List<SongsData> songsList = <SongsData>[];
  bool isListReady = false;
  var snapshot;
  var playlistRef;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPlaylistData();
  }

  getPlaylistData()async{
    // MyProgress().showLoaderDialog(context);
    if(!isIdInit) {
      myId = await FirebaseAuth.instance.currentUser!.uid.toString();
      isIdInit = true;
    }

    playlistRef = await FirebaseFirestore.instance.collection("MyPlayLists").doc(myId).collection("Lists").doc(playlistId);
    snapshot = await playlistRef.get();
    playlistData = await PlayListData
        .fromMap(snapshot.data() as Map<String, dynamic>);

    playlistName = playlistData.playListName;
    songsIdList = playlistData.songlist;
    // Navigator.pop(context);
    setState(() {

    });

    getSongs(songsIdList);


  }

  getSongs(List<String> songIdList) async{

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

    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    playlistId = data["listId"]==null? "" : data["listId"];

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
          playlistName,
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
                "listId": playlistId,
                "type" : "all",
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
                              removeFromPlaylist(song);

                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
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

  removeFromPlaylist(SongsData song) async{
    var songName = song.songName;

    var playlistRef = await FirebaseFirestore
        .instance.collection("MyPlayLists")
        .doc(myId).collection("Lists").doc(
        playlistId);
    var snapshot = await playlistRef.get();
    PlayListData playlistData = await PlayListData
        .fromMap(snapshot.data() as Map<String, dynamic>);

    var playlist = playlistData.songlist;



    if(playlist.length == 1){
      playlist[0] = "";
    }
    else{
      playlist.remove(song.songId);
    }

    await playlistRef.update({"NoOfSong": --playlistData.numberofSong});
    playlistRef.update({"SongList":playlist}).whenComplete((){
      Navigator.pop(context);
      MySnackBar().showSnackbar(context, songName + " successfully removed from playlist!");
      isListReady = false;
      getPlaylistData();
      setState(() {

      });
    });


    print("play list length" + playlist.length.toString());

    // if(songFound) {
    //   Navigator.pop(context);
    //   MySnackBar().showSnackbar(context, "Song already exists in playlist!");
    // }
    // else{
    //   playlist.add(song.songId);
    //   await playlistRef.update({"NoOfSong": ++playlistData.numberofSong});
    //   playlistRef.update({"SongList":playlist}).whenComplete((){
    //     Navigator.pop(context);
    //     MySnackBar().showSnackbar(context, song.songName + " successfully added to playlist!");
    //     setState(() {
    //
    //     });
    //   });
    // }
  }
}
