import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:surat_weavers_v3/auths/firebase_auth.dart';
import 'package:surat_weavers_v3/auths/getStorage_pref.dart';
import 'package:surat_weavers_v3/auths/google_signIn_auth.dart';
import 'package:surat_weavers_v3/main.dart';
import 'package:surat_weavers_v3/screens/home_screen.dart';
import 'package:surat_weavers_v3/screens/registration_screen.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

String otpcheck = '';
String currentuser = '';

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  String otpVerification = '';
  Future testingOtp() async {
    String testing = await otpVerificationStatus();
    setState(() {
      otpVerification = testing;
    });
  }

  Future _getRegistrationData() async {
    var docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(kFirebase.currentUser!.email);
    var snapshotRef = await docRef.get();
    return snapshotRef.exists;
  }

  _onPressGoogleSignIn() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("please wait...")));
    await signInWithGoogle().then(
      (value) async {
        var isRegistered = await _getRegistrationData();
        log("is user registered? $isRegistered");
        StoragePref.setUsername(
            username: currentUsername ?? "error , please re-login");
        isRegistered
            ? pageTransition(
                context: context, screen: HomeScreen(), replacement: true)
            : pageTransition(
                context: context,
                screen: RegistrationScreen(),
                replacement: true);
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog(
            //show confirm dialogue
            //the return value will be from "Yes" or "No" options
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Exit App'),
              content: Text('Do you want to exit an App?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  //return false when click on "NO"
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  //return true when click on "Yes"
                  child: Text('Yes'),
                ),
              ],
            ),
          ) ??
          false; //if showDialouge had returned null, then return false
    }

    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        backgroundColor: Color(0xffFF324BCD),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/rating_logo.png',
                      height: 120.sp),
                ),
                Text(
                  'Welcome,',
                  style: TextStyle(color: Colors.white, fontSize: 30.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Sign In through your google id : ',
                  style: TextStyle(color: Colors.white, fontSize: 17.sp),
                ),
                SizedBox(height: 3.h),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                    onPressed: _onPressGoogleSignIn,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/googleLogo.png',
                          height: 14.sp,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Google',
                          style: TextStyle(
                              color: Color(0xffFF324BCD), fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
