import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trax_xone/pages/CreateProfilePage.dart';
import 'package:trax_xone/pages/Home.dart';
import 'package:trax_xone/pages/Login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  var alignment = Alignment(0, -2.5);
  var textAlignment = Alignment(-4.5, 0);



  //for animation app logo...
  void setAlignmentAnimation() {
    
    alignment = Alignment(0, -0.075);
    setState(() {

    });
    
  }

  bool? isLogedIn = false;
  bool isProfileCreated = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void runAnimation() async{
    SharedPreferences preferences = await _prefs;
    isLogedIn = preferences.getBool('isLogedIn')??false;
    isProfileCreated = preferences.getBool("isProfileCreated")?? false;

    Timer(Duration(seconds: 1), () {
      setAlignmentAnimation();
      Timer(Duration(seconds: 2), () {
        textAlignment = Alignment(0, 0);
        setState(() {

        });
        Timer(Duration(seconds:3), () {


        if(isLogedIn!&&isProfileCreated){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context)=>Home())
          );
        }
        else if(!isLogedIn!){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context)=>Login())
          );
        }
        else{
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context)=>CreateProfilePage())
          );
        }



      });
      });
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    runAnimation();

  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.height/2-200),
          children: [
            //app splash screen background...
            Image(
              image: AssetImage('assets/backgrounds/splash_new_bg.png'),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),

            //app logo animations...
            Center(
              child: AnimatedContainer(
                duration: Duration(seconds: 2),
                alignment: alignment,
                curve: Curves.bounceOut,
                //app logo...
                child: Image(
                  image: AssetImage('assets/icons/trax_xone_round.png'),
                  width: 140,
                  height: 140,
                ),
              ),
            ),

            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
              alignment: textAlignment,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 140,),
                    Text(
                      "Trax Xone",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Reform",
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
