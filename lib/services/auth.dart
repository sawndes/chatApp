import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_clone/helperfunctions/sharepref_helper.dart';
import 'package:messenger_clone/services/database.dart';
import 'package:messenger_clone/views/home.dart';
import 'package:messenger_clone/views/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User userDetails = result.user!;

    if (result != null) {
      SharedPreferenceHelper().saveUserEmail(userDetails.email!);
      SharedPreferenceHelper()
          .saveUserName(userDetails.email!.replaceAll('@gmail.com', ''));
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      SharedPreferenceHelper().saveDisplayName(userDetails.displayName!);
      SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL!);
      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email!.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
      };
      DatabaseMethods()
          .addUserInfoToDB(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      });
    }
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await auth.signOut();
    prefs.clear();
  }
}
