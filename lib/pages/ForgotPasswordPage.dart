
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/MyProgress.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  var _emailText = TextEditingController();


  String? emailError = "";
  bool isEmailError = false;
  bool isEmailSent = false;

  void resetPassword()async{
    final bool emailValid =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_emailText.text.toString().trim());


    if (emailValid ){
      setState(() {
        emailError = '';
        isEmailError = false;
      });
      MyProgress().showLoaderDialog(context);

      //reset password...
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailText.text.toString().trim());
        Navigator.pop(context);
        setState(() {
          isEmailSent = true;
        });

      }
      on FirebaseAuthException catch(e) {
        if(e.code == 'user-not-found'){
          setState(() {
            isEmailSent = false;
            emailError = 'user-not-found';
            isEmailError = true;
          });
        }
        else{

        }
        Navigator.pop(context);
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
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        shadowColor: Colors.transparent,
      ),

      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.pink.shade900, Colors.pink.shade900, Colors.pink.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2),
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.0),

                      // login and welcome heading...
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "Receive an e-mail to reset\nyour password",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontFamily: "Reform",
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )

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

                            // //please Check text...
                            Column(
                              children: [
                                Visibility(
                                  visible: isEmailSent,
                                  child: Text(
                                    "Please check your e-mail",
                                    style: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontFamily: "Reform",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
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

                        SizedBox(height: 36,),

                        //reset password button...
                        Center(
                          child: ElevatedButton(
                              onPressed: () async{

                                resetPassword();

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
                                  "Reset Password",
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
