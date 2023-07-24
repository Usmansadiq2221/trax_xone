
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_cutter/audio_cutter.dart';
import 'package:trax_xone/components/WaveSlider.dart';

import '../components/MyProgress.dart';

class EditSong extends StatefulWidget {
  EditSong({Key? key}) : super(key: key);

  @override
  State<EditSong> createState() => _EditSongState();
}

class _EditSongState extends State<EditSong> with TickerProviderStateMixin {

  late AnimationController animationController;
  bool isPlaying = false;
  Map data = {};

  var audioPlayer = AudioPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String songFilePath = "";
  String trimAudioFilePath = "";

  var rotaionAngle = 0.0;
  late final Duration? audioDuration;
  double? durationInSec = 0.0;

  double trimStart=0.0;
  double trimEnd=0.0;
  String outputFilePath = "";
  bool isAudioTrimed = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //loading audio file from passed path...
    loadAudio();

    //play audio from file selected from storage...
    // playAudio();

    //get the total duration of the song...
    // getSongDuration(audioPlayer);


    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
    });

    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 12000),
    );
    animationController.forward();
    animationController.addListener(() {
      setState(() {
        if (animationController.status == AnimationStatus.completed) {
          animationController.repeat();
        }
      });
    });
    animationController.stop();
  }


  void loadAudio() async{
    data = await data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    songFilePath = data["songFile"];
    playAudio(songFilePath);
  }

  void playAudio(String songFilePath) async{
    MyProgress().showLoaderDialog(context);
    await audioPlayer.play(UrlSource(songFilePath));
    Navigator.pop(context);

    if(!isPlaying){
      print("Hellow Player");
      await audioPlayer.resume();
      isPlaying = true;
      animationController.repeat();

    }else{
      await audioPlayer.pause();
      isPlaying = false;
      animationController.stop();
    }
    setState(() {

    });
    if(!isAudioTrimed) {
      getSongDuration(audioPlayer);
    }
  }

  void getSongDuration(AudioPlayer audioPlayer) async{
    audioDuration = await audioPlayer.getDuration();
    if (audioDuration != null) {
      durationInSec = audioDuration!.inSeconds.toDouble();
      setState(() {

      });
      print('Audio Duration (in seconds): $durationInSec');
      // Pass the durationInSeconds as a double parameter to another function
      // or use it as needed.
    } else {
      print('Unable to retrieve audio duration.');
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
    audioPlayer.stop();
    audioPlayer.dispose();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    audioPlayer.stop();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {



    // data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map;
    // songFilePath = data["songFile"];
    // print("Hello Duration: " + durationInSec.toString());


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



    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Song",
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Reform",
                  fontSize: 24,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height/15,
                width: MediaQuery.of(context).size.width,
              ),

              AnimatedBuilder(
                animation: animationController,
                child: Card(
                  color: Colors.transparent,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width),
                  ),
                  child: CircleAvatar(
                    foregroundImage: AssetImage('assets/backgrounds/track_edit_image.png'),
                    backgroundColor: Colors.transparent,
                    radius: MediaQuery.of(context).size.width/2.4,
                  ),
                ),
                builder: (BuildContext context, Widget? _widget) {
                  return new Transform.rotate(
                    angle: animationController.value * 6.3,
                    child: _widget,
                  );
                },
              ),

              SizedBox(height: 24,),

              ProgressBar(
                progress: Duration(seconds: position.inSeconds),
                buffered: Duration(seconds: position.inSeconds),
                total: Duration(seconds: duration.inSeconds),
                thumbColor: Colors.red.shade900,
                baseBarColor: Colors.grey,
                barHeight: 2,
                bufferedBarColor: Colors.grey.shade700,
                timeLabelPadding: 12,
                timeLabelTextStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Reform",
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3
                ),
                thumbGlowRadius: 24,
                progressBarColor: Colors.red.shade900,
                onSeek: (value)async{
                  final position = value;
                  await audioPlayer.seek(position);
                },

              ),

              SizedBox(height: 36,),


              SizedBox(width: 32,),



              // play song Button...
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: ()async{
                      MyProgress().showLoaderDialog(context);
                      await audioPlayer.play(UrlSource(songFilePath));
                      Navigator.pop(context);

                      if(!isPlaying){
                        print("Hellow Player");
                        await audioPlayer.resume();
                        isPlaying = true;
                        animationController.repeat();

                      }else{
                        await audioPlayer.pause();
                        isPlaying = false;
                        animationController.stop();
                      }
                      setState(() {

                      });

                    },
                    child: Icon(
                      isPlaying? Icons.pause : Icons.play_arrow,
                      color: Colors.grey.shade100,
                      size: 56,
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
              ),
              SizedBox(height: 28,),

              //Audio Trimmer wave slider...
              Center(
                child: WaveSlider(
                  backgroundColor: Colors.transparent,
                  heightWaveSlider: 90,
                  widthWaveSlider: 320,
                  sliderColor: Colors.red.shade900,
                  wavActiveColor: Colors.white,
                  wavDeactiveColor: Colors.red.shade900,
                  duration: durationInSec!,
                  callbackStart: (duration) {
                    trimStart = duration;
                    print("Start $duration");
                  },
                  callbackEnd: (duration) {
                    trimEnd = duration;
                    print("End $duration");
                  },
                ),
              ),

              //audio trim and save button...
              Row(
                children: [
                  SizedBox(width: 36,),

                  //Trim Audio...
                  ElevatedButton(
                    onPressed: () async{
                      // Get path to cut file and do whatever you want with it.
                      audioPlayer.stop();
                      MyProgress().showLoaderDialog(context);
                      var outputFilePath = await AudioCutter.cutAudio(songFilePath, trimStart, trimEnd==0.0? durationInSec!:trimEnd);
                      trimAudioFilePath = outputFilePath.toString();
                      isAudioTrimed = true;
                      print("SongPath: "+songFilePath);

                      //play trimmed audio file...
                      playAudio(trimAudioFilePath);
                      Navigator.pop(context);
                      setState(() {

                      });
                    },
                    child: Text(
                      "Trim",
                      style: TextStyle(
                        fontFamily: "Reform",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      padding: EdgeInsets.only(bottom: 8),
                      minimumSize: Size(MediaQuery.of(context).size.width/3.5, 32),
                      elevation: 6,
                    ),
                  ),
                  Expanded(child: Container()),

                  //save audio file button...
                  ElevatedButton(
                    onPressed: (){
                      audioPlayer.stop();
                      audioPlayer.dispose();
                      Navigator.pop(context, trimAudioFilePath);

                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontFamily: "Reform",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.only(bottom: 8),
                      minimumSize: Size(MediaQuery.of(context).size.width/3.5, 32),
                      elevation: 6
                    ),
                  ),
                  SizedBox(width: 36,)
                ],
              )



            ],
          ),
        ),
      ),
    );
  }
}

