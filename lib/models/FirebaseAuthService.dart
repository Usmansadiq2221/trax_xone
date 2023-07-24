import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService{

  signInWithGoogle() async {
    //begin interactive sign in process...
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    //obtain auth details from request...
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    //create a new credential for auth...
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //finally, lets sign in...
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

}