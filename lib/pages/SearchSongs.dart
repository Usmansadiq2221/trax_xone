
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/components/mySnackbar.dart';
import 'package:trax_xone/models/PlayListData.dart';
import 'package:trax_xone/models/SongsData.dart';

class SearchSongs extends StatefulWidget {
  const SearchSongs({Key? key}) : super(key: key);

  @override
  State<SearchSongs> createState() => _SearchSongsState();
}

class _SearchSongsState extends State<SearchSongs> {

  var songName = TextEditingController();
  Map data = {};
  String type = "";
  String playlistId = "";
  List<String> playlist = <String>[];
  List<SongsData> songList = [];

  List<PlayListData> prePlayList = [];

  late String myId;

  final songsRef = FirebaseFirestore.instance.collection('Songs');



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("Hello List");
    
    fetchSongsData();
  }

  
  Future<List<SongsData>> getSongDocs() async{

    List<SongsData>  sList= <SongsData>[];

    // songsRef.get().then((QuerySnapshot snapshot ) {
    //   snapshot.docs.forEach((DocumentSnapshot doc){
    //     SongsData songsData = SongsData.fromMap(doc.data());
    //     print(doc.data());
    //   });
    // });


    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Songs').get();
    querySnapshot.docs.forEach((doc) {
      SongsData songsData = SongsData.fromMap(doc.data() as Map<String, dynamic>);

      if(type=="all"){
        sList.add(songsData);
      }
      else {
        if (type == songsData.songType) {
          sList.add(songsData);
        }
      }
    });

    return sList;
  }

  void fetchSongsData() async{
    playlist.clear();
    myId = await FirebaseAuth.instance.currentUser!.uid.toString();

    songList = await getSongDocs();

    if(playlistId.length>1) {
      var playlistRef = await FirebaseFirestore.instance.collection(
          "MyPlayLists").doc(myId).collection("Lists").doc(playlistId).get();
      PlayListData playlistData = await PlayListData.fromMap(
          playlistRef.data() as Map<String, dynamic>);
      playlist = playlistData.songlist;
    }

    setState(() {

    });
    // Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {
    //getting data sent from previous page...
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    type = data["type"]==null? "all" : data["type"];

    playlistId = data["listId"]==null? "" : data["listId"];
    print(type);
    print(playlistId);

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              //search song text field...
              SizedBox(
                height: 42,
                width: MediaQuery.of(context).size.width-42,
                child: TextField(
                  controller: songName,
                  cursorColor: Colors.red.shade900,
                  keyboardType: TextInputType.name,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
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
                    ),
                    hintText: "Search Song",
                  ),
                ),
              ),
              SizedBox(height: 8,),

              //displaying songs list...
              Container(
                width: MediaQuery.of(context).size.width,
                height : MediaQuery.of(context).size.height-120,
                child: ListView.builder(
                    itemCount: songList.length,
                    itemBuilder: (context, index) {

                      SongsData song= songList[index] as SongsData;
                      bool isAdded = false;

                      if(playlistId.length>1){
                        for(String currentSong in playlist){
                          if(currentSong == song.songId){
                            isAdded = true;
                          }
                        }
                      }

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
                                    'songList' : songList
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

                                      if (playlistId.length>1) {
                                        MyProgress().showLoaderDialog(context);
                                        addToPlaylist(song);
                                      }
                                      else{
                                        MyProgress().showLoaderDialog(context);
                                        getPlaylists(song);
                                      }

                                    },
                                    icon: Icon(
                                      Icons.add_circle_outline_outlined,
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
                )
              ),

            ],
          ),
        )
      ),

    );
  }

  addToPlaylist(SongsData song) async{

    var playlistRef = await FirebaseFirestore
        .instance.collection("MyPlayLists")
        .doc(myId).collection("Lists").doc(
        playlistId);
    var snapshot = await playlistRef.get();
    PlayListData playlistData = await PlayListData
        .fromMap(snapshot.data() as Map<String, dynamic>);

    playlist = playlistData.songlist;
    if(playlist[0].length<2){
      playlist.clear();
    }

    var songFound = false;

    playlist.add(song.songId);
    await playlistRef.update({"NoOfSong": ++playlistData.numberofSong});
    playlistRef.update({"SongList":playlist}).whenComplete((){
      Navigator.pop(context);
      MySnackBar().showSnackbar(context, song.songName + " successfully added to playlist!");
      setState(() {

      });
    });

    if(playlistData.numberofSong>0) {
      for(String item in playlist) {
        if(item == song.songId){
          songFound = true;
        }
      }
    }
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

  getPlaylists(SongsData song) async{
    print("Hello Success");

    prePlayList.clear();

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('MyPlayLists').doc(myId).collection("Lists").get();
    querySnapshot.docs.forEach((doc) {

      PlayListData playListData = PlayListData.fromMap(doc.data() as Map<String, dynamic>);
      prePlayList.add(playListData);

    });

    print("No of Lists: "+prePlayList.length.toString());

    Navigator.pop(context);

    if(prePlayList.length>0) {
      showPlaylistDialoge(prePlayList, song);
    }
    else{
      MySnackBar().showSnackbar(context, "No Plsylist exists\nCreate new playlists to add songs! ");
    }
    setState(() {

    });

  }

  showPlaylistDialoge(List<PlayListData> list, SongsData song){

    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Card(
            margin: EdgeInsets.only(left: 32, right: 32, top:0),
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
              height: 310,
              width: MediaQuery.of(context).size.width-100,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 12,),
                  Text(
                    "Playlists",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 24,
                        fontFamily: "Reform",
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 2,),
                  Container(
                    height: 260,
                    width: MediaQuery.of(context).size.width-100,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      itemCount: list.length,
                      itemBuilder: (context, index){
                        PlayListData playListData = list[index]as PlayListData;
                        return SingleChildScrollView(
                          child:InkWell(
                            child: Column(
                              children: [
                                SizedBox(height: 6,),
                                //playlist info...
                                Row(
                                  children: [
                                    Image(
                                      image: AssetImage("assets/icons/urdu_song.png"),
                                      height: 24,
                                    ),
                                    SizedBox(width: 12,),

                                    //playlist name...
                                    Column(
                                      children: [
                                        Text(
                                          playListData.playListName,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18,
                                              fontFamily: "Reform",
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(height: 8,)
                                      ],
                                    ),



                                  ],
                                ),
                                SizedBox(height: 6,),

                                Container(
                                  height: 1,
                                  color: Colors.grey,
                                ),

                              ],
                            ),
                            onTap: (){
                              addToSpecificPlaylist(playListData.playListId, song);
                            },
                          )
                        );
                      },
                    ),
                  ),
                ],
              )
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

  addToSpecificPlaylist(String listId, SongsData song) async{
    MyProgress().showLoaderDialog(context);
    var playlistRef = await FirebaseFirestore
        .instance.collection("MyPlayLists")
        .doc(myId).collection("Lists").doc(
        listId);
    var snapshot = await playlistRef.get();
    PlayListData playlistData = await PlayListData
        .fromMap(snapshot.data() as Map<
        String,
        dynamic>);

    playlist = playlistData.songlist;
    if(playlist[0].length<2){
      playlist.clear();
    }

    var songFound = false;

    if(playlistData.numberofSong>0) {
      for(String item in playlist) {
        if(item == song.songId){
          songFound = true;
        }
      }
    }


    if(songFound) {
      Navigator.pop(context);
      MySnackBar().showSnackbar(context, "Song already exists in playlist!");
    }
    else{
      playlist.add(song.songId);
      await playlistRef.update({"NoOfSong": ++playlistData.numberofSong});
      playlistRef.update({"SongList":playlist}).whenComplete((){
        Navigator.pop(context);
        Navigator.pop(context);
        MySnackBar().showSnackbar(context, song.songName + " successfully added to playlist!");
        setState(() {

        });
      });
    }



    print("play list length" + playlist.length.toString());

  }



}
