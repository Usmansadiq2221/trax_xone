

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trax_xone/models/StorageSongsData.dart';

class MyMusicTab extends StatefulWidget {
  const MyMusicTab({Key? key}) : super(key: key);

  @override
  State<MyMusicTab> createState() => _MyMusicTabState();
}

class _MyMusicTabState extends State<MyMusicTab> {


  final OnAudioQuery _audioQuery = OnAudioQuery();
  AudioPlayer audioPlayer = AudioPlayer();

  late final List<SongModel> songs;
  List<StorageSongsData> songList = <StorageSongsData>[];

  bool isListReady = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getStoragePermit();

  }

  getStoragePermit() async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
      Permission.audio,
      Permission.videos,
    ].request();

    if(statuses[Permission.storage]!.isGranted && statuses[Permission.photos]!.isGranted && statuses[Permission.audio]!.isGranted && statuses[Permission.videos]!.isGranted ){
      print("Permission Granted");
      getAudioFiles();

    }
    else{
    if(statuses[Permission.storage]!.isDenied && statuses[Permission.photos]!.isDenied && statuses[Permission.audio]!.isDenied && statuses[Permission.videos]!.isDenied){
    statuses = await [
      Permission.storage,
      Permission.photos,
      Permission.audio,
      Permission.videos,
    ].request();
    }
    if(statuses[Permission.storage]!.isPermanentlyDenied || statuses[Permission.photos]!.isPermanentlyDenied && statuses[Permission.audio]!.isPermanentlyDenied && statuses[Permission.videos]!.isPermanentlyDenied){
      openAppSettings();
    }
    print("permission not granted");
    }
  }



  getAudioFiles() async{
    songs = await _audioQuery.querySongs() ;
    songs.forEach((element) {
      if(element.duration!>60000) {

        songList.add(StorageSongsData(path: element.data, title: element.title, artist: element.artist?? "Unknown", coverId: element.id));

      }
    });
    setState(() {
      isListReady = true;
    });




    print("Songs in Storage : " + songList.length.toString());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: isListReady ? ListView.builder(
        itemCount: songList.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey.shade900,
            elevation: 12,
            child: ListTile(
              minVerticalPadding: 12,
              onTap: (){

                Navigator.pushNamed(context, '/playStorageSong',arguments: {
                  'songIndex' : index,
                  'songList' : songList
                });

              },
              title: Text(
                songList[index].title,
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Reform",
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                songList[index].artist,
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Reform",
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.grey,
              ),
              // This Widget will query/load image.
              // You can use/create your own widget/method using [queryArtwork].
              leading: QueryArtworkWidget(
                controller: _audioQuery,
                id: songList[index].coverId,
                type: ArtworkType.AUDIO,
                nullArtworkWidget:  CircleAvatar(
                  child: Image(image: AssetImage('assets/icons/trax_xone_round.png')),
                ),
              ),
            ),
            margin: EdgeInsets.only(left: 18, right: 18, top: index==0 ? 18 : 6, bottom: index==songList.length-1 ? 18 : 6),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            ),


          );
        },
      ) :
    Center(
        child: Text(
          "This tab is under development",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

      ),
    );
  }


}
