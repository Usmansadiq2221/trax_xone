import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trax_xone/components/MyProgress.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {


  var _emailText = TextEditingController();
  var _passwordText = TextEditingController();
  var _cPasswordText = TextEditingController();

  String? emailError = "";
  bool isEmailError = false;

  String passwordError = "";
  bool isPasError = false;


  void signupWithEmail() async{
    final bool emailValid =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_emailText.text.toString().trim());

    final bool passwordValid =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(_passwordText.text.toString().trim());


    if (emailValid && passwordValid &&
        _passwordText.text.toString()==_cPasswordText.text.toString()){
      setState(() {
        emailError = '';
        isEmailError = false;
        passwordError = '';
        isPasError = false;
      });
      MyProgress().showLoaderDialog(context);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailText.text.trim(),
          password: _passwordText.text.trim(),
        );
        FirebaseAuth.instance
            .userChanges()
            .listen((User? user) async{
          if (user == null) {
            print('User is currently signed out!');
          } else {
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setBool('isLogedIn', true);
            Navigator.pop(context);
            Navigator.popAndPushNamed(context, '/createProfile');

          }
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            passwordError = 'Password must contains at least 8 characters, at least one uppercase letter, at least one lowercase letter, at least one numeric digit and at least one special character';
            isPasError = true;
          });

        } else if (e.code == 'email-already-in-use') {
          setState(() {
            emailError = 'The account already exists for that email.';
            isEmailError = true;
          });
        }
        else {
          setState(() {
            passwordError = 'Network Problem please check your internet connection';
            isPasError = true;
          });
        }
        Navigator.pop(context);
      } catch (e) {
        print(e);
      }
    }
    else{
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
      else if(_passwordText.text.toString().trim()!=_cPasswordText.text.toString().trim()){
        setState(() {
          passwordError = "Password & Confirm password not matched";
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
                            "Sign up",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 4,),
                          Text(
                            "Welcome here",
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
                                  "Pleae sign up to continue",
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
                            keyboardType: TextInputType.visiblePassword,
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
                              hintText: "Password",
                            ),
                          ),
                        ),
                        SizedBox(height: 16,),

                        //confirm password text field...
                        SizedBox(
                          height: 42,
                          width: MediaQuery.of(context).size.width-64,
                          child: TextField(
                            controller: _cPasswordText,
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
                              hintText: "Confirm Password",
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

                        SizedBox(height: 42,),

                        //sign up button...
                        Center(
                          child: ElevatedButton(
                              onPressed: () async{
                                //call function to create new user...
                                signupWithEmail();

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
                                    stops: [0.1,0.9]
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Sign up",
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
                        SizedBox(height: 6,),

                        // sing in text...
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
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontFamily: "Reform",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),


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
