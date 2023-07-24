import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trax_xone/pages/CreateProfilePage.dart';
import 'package:trax_xone/pages/EditProfile.dart';
import 'package:trax_xone/pages/EditSongPage.dart';
import 'package:trax_xone/pages/ForgotPasswordPage.dart';
import 'package:trax_xone/pages/Home.dart';
import 'package:trax_xone/pages/Login.dart';
import 'package:trax_xone/pages/MySavedSongs.dart';
import 'package:trax_xone/pages/PlaySongPage.dart';
import 'package:trax_xone/pages/PlayStorageSong.dart';
import 'package:trax_xone/pages/PrivacyPolicy.dart';
import 'package:trax_xone/pages/SearchSongs.dart';
import 'package:trax_xone/pages/SignupPage.dart';
import 'package:trax_xone/pages/ViewPlaylist.dart';
import 'package:trax_xone/pages/splash_screen.dart';

import 'firebase_options.dart';

void main() async{
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trax Xone',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(255, 0, 56, 1),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color.fromRGBO(255, 0, 56, 1),
          secondary: Colors.grey.shade600,
        )
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context)=>Home(),
        '/search': (context)=>SearchSongs(),
        '/login': (context)=>Login(),
        '/createProfile': (context)=>CreateProfilePage(),
        '/signup': (context)=>SignupPage(),
        '/playSong':(context)=>PlaySongPage(),
        '/forgotPassword': (context)=>ForgotPassword(),
        '/editProfile':(context)=>EditProfile(),
        '/editSong': (context)=>EditSong(),
        '/viewPlaylist': (context)=>ViewPlaylist(),
        '/mySaved': (context)=>MySavedSongs(),
        '/privacy': (context)=>PrivacyPolicy(),
        '/playStorageSong' : (context)=>PlayStorageSong()
      },
    );
  }
}
