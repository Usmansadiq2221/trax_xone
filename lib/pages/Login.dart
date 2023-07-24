import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trax_xone/components/MyProgress.dart';
import 'package:trax_xone/models/FirebaseAuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var _emailText = TextEditingController();
  var _passwordText = TextEditingController();

  String? emailError = "";
  bool isEmailError = false;

  String passwordError = "";
  bool isPasError = false;

  /// Check If Document Exists
  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('Users');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  void customSignIn() async{
    final bool emailValid =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_emailText.text.toString().trim());

    final bool passwordValid =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(_passwordText.text.toString().trim());

    if (emailValid && passwordValid){

      MyProgress().showLoaderDialog(context);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailText.text.trim(),
            password: _passwordText.text.trim()
        );
        FirebaseAuth.instance
            .userChanges()
            .listen((User? user) async{
          if (user == null) {
            print('User is currently signed out!');
          } else {
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setBool('isLogedIn', true);

            String? userId = await FirebaseAuth.instance.currentUser?.uid.toString();
            bool docExists = await checkIfDocExists(userId!);
            Navigator.pop(context);
            if(!docExists){
              Navigator.pushReplacementNamed(context, '/createProfile');
            }
            else {
              Navigator.pushReplacementNamed(context, '/home');
            }

          }
        });

      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          emailError = 'No user found for that email.';
          isEmailError = true;
        }
        else if (e.code == 'wrong-password') {
          setState(() {
            passwordError = 'Wrong password provided for that user.';
            isPasError = true;
          });
        }
        Navigator.pop(context);
      }
    }
    else {
      if(!emailValid){
        setState(() {
          emailError = 'Invalid email';
          isEmailError = true;
        });
      }
      else{
        setState(() {
          emailError = '';
          isEmailError = false;
        });
      }
      if(!passwordValid){
        setState(() {
          passwordError = 'Password must contains at least 8 characters, at least one uppercase letter, at least one lowercase letter, at least one numeric digit and at least one special character';
          isPasError = true;
        });
      }
      else{
        setState(() {
          passwordError = '';
          isPasError = false;
        });
      }

    }
  }

  void signInWithGoogle() async{
    print("Hellow Login");
    MyProgress().showLoaderDialog(context);
    await FirebaseAuthService().signInWithGoogle();
    FirebaseAuth.instance
        .userChanges()
        .listen((User? user) async{
      if (user == null) {
        print('User is currently signed out!');
      }
      else {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setBool('isLogedIn', true);

        String? userId = await FirebaseAuth.instance.currentUser?.uid.toString();
        bool docExists = await checkIfDocExists(userId!);
        Navigator.pop(context);
        if(!docExists){
          Navigator.pushReplacementNamed(context, '/createProfile');
        }
        else {
          await pref.setBool('isProfileCreated', true);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.pink.shade900, Colors.pink.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height/20,),
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.0),

                      // login and welcome heading...
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 4,),
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 6,),
                          Text(
                            "Listen your favourite songs",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //round top_radius container...
                    Column(
                      children: [
                        SizedBox(height: (MediaQuery.of(context).size.height/9)+32,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black, Colors.grey.shade900],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 6
                            )],
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40)
                            )
                          ),
                          child: Column(
                            children: [
                              Expanded(child: Container())
                            ],
                          ),
                        ),
                      ],
                    ),

                    //login headings and headset image and login details fields...
                    Column(
                      children: [
                        SizedBox(height: 36,width: MediaQuery.of(context).size.width,),

                        // headset image and please text layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(width: 32,),

                            //please login text...
                            Column(
                              children: [
                                Text(
                                  "Pleae sign in to continue",
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                    fontFamily: "Reform",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),SizedBox(height: 12,)
                              ],
                            ),
                            Expanded(child: Container()),

                            //headset image...
                            Image(
                              image: AssetImage('assets/backgrounds/grey_headset.png'),
                              height: 140,
                            ),
                          ],
                        ),
                        SizedBox(height: 32,),

                        //email text field...
                        SizedBox(
                          height: 42,
                          width: MediaQuery.of(context).size.width-64,
                          child: TextField(
                            controller: _emailText,
                            cursorColor: Colors.red.shade900,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
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
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: "Your e-mail?",
                            ),
                          ),
                        ),
                        //email error text...
                        Visibility(
                          visible: isEmailError,
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 36,top: 3),
                            child: Text(
                              emailError!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),

                        //password text field...
                        SizedBox(
                          height: 42,
                          width: MediaQuery.of(context).size.width-64,
                          child: TextField(
                            controller: _passwordText,
                            cursorColor: Colors.red.shade900,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_open_rounded,
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
                                fontWeight: FontWeight.bold
                              ),
                              hintText: "Your password?",
                            ),
                          ),
                        ),
                        //password error text...
                        Visibility(
                          visible: isPasError,
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 36,top: 3,right: 36),
                            child: Text(
                              passwordError!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6,),

                        //forgot text...
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 36),
                          child: InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, '/forgotPassword');
                            },
                            child: Text(
                              "Forgot Password",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28,),

                        //sign in button...
                        Center(
                          child: ElevatedButton(
                              onPressed: () async{
                                customSignIn();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                minimumSize: Size(150, 24),
                                padding: EdgeInsets.all(0),
                              ),
                              child: Container(
                                width: 150,
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
                                  "Sign in",
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
                        ),
                        SizedBox(height: 4,),

                        // Or text...
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              height: 2,
                              width: 50,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade900, Colors.pink.shade900],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  )
                              ),
                            ),

                            //or Text
                            Column(
                              children: [
                                Text(
                                  "Or",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "Reform",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4,)
                              ],
                            ),

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              height: 2,
                              width: 50,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade900, Colors.pink.shade900],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 28,),

                        //login with google button...
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 6,
                          color: Colors.red.shade900,
                          child: InkWell(
                            onTap: ()async{
                              signInWithGoogle();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width-64,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 8,),
                                  Image(image: AssetImage('assets/icons/google_icon.png'), color: Colors.grey.shade100, height: 26,),
                                  SizedBox(width: 12,),

                                  //login with google text...
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Login with google",
                                        style: TextStyle(
                                          color: Colors.grey.shade100,
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
                          ),
                        ),
                        SizedBox(height: 12,),

                        // sing up text...
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Reform",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.pushReplacementNamed(context, '/signup');
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontFamily: "Reform",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )


                      ],
                    ),


                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
