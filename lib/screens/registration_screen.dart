import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:surat_weavers_v3/auths/firebase_auth.dart';
import 'package:surat_weavers_v3/auths/google_signIn_auth.dart';
import 'package:surat_weavers_v3/screens/verify_otp.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

String? verificationCode;

class _RegistrationScreenState extends State<RegistrationScreen> {
  int? resendingTokenID;
  FirebaseAuth auth = FirebaseAuth.instance;

  final _address = TextEditingController();
  final _companyName = TextEditingController();
  final _mobile = TextEditingController();
  final _gstNo = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();

  _onPressSubmit() async {
    /*  if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('MainPartyDataCenter')
          .doc(_gstNo.text.toString().toUpperCase())
          .set({
        'address': _address.text.toString(),
        'company_name': _companyName.text.toString().capitalize,
        'gst_no': _gstNo.text.toString().toUpperCase(),
        'mobile': _mobile.text.toString(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(kFirebase.currentUser!.uid)
          .set({
        'address': _address.text.toString(),
        'company_name': _companyName.text.toString().capitalize,
        'gst_no': _gstNo.text.toString().toUpperCase(),
        'mobile': _mobile.text.toString(),
      }).then((value) async {
        double zeroInDouble = 0;
        await FirebaseFirestore.instance
            .collection('rating')
            .doc(_gstNo.text.toString().toUpperCase())
            .set({
          'party_address': _address.text,
          'party_company_name': _companyName.text.toString(),
          'party_gst_no': _gstNo.text.toString().toUpperCase(),
          'party_mobile': _mobile.text,
          'avg rating': 0.0,
          'who rated': {},
          'comments': {},
        }).then(
          (value) => sendOTP(auth).then(
            (value) async {
              // final signature =
              // await SmsAutoFill().getAppSignature;
              // return Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => VerifyOTP(),
              //   ),
              // );
            },
          ),
        );
      });
    }*/
    sendOTP(FirebaseAuth.instance).then(
      (value) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VerifyOTPScreen(
            companyName: _companyName.text.trim().capitalize!,
            address: _address.text.trim().capitalize!,
            gstno: _gstNo.text.trim().toUpperCase(),
            phoneNumber: _mobile.text.trim(),
          ),
        ));
      },
    );
  }

  Future sendOTP(FirebaseAuth auth) async {
    await auth.verifyPhoneNumber(
        phoneNumber: '+91 ${_mobile.text}',
        verificationCompleted: (phoneAuthCredential) async {
          log('Verification Completed');
        },
        verificationFailed: (verificationFailed) async {
          log("verificationFailed error ${verificationFailed.message}");
          /*  ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(verificationFailed.message!),
              )
          );*/
        },
        codeSent: (verificationId, forceResendingToken) async {
          verificationCode = verificationId;
          resendingTokenID = forceResendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) async {});
    // print("CountryCode===>>>");
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
        // resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      // alignment: Alignment.center,
                      child: Image.asset('assets/images/rating_logo_2.png',
                          height: 210.sp),
                    ),
                    // Spacer(flex: 1),
                    TextFormField(
                      controller: _companyName,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'fill this field';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Company Name',
                        labelText: 'Company Name',
                        suffixIcon: Icon(Icons.business_sharp),
                      ),
                    ),
                    Spacer(flex: 1),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _mobile,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'fill this field';
                        }
                      },
                      maxLength: 10,
                      decoration: InputDecoration(
                        prefix: Text('+91'),
                        hintText: 'Mobile No.',
                        labelText: 'Mobile No.',
                        suffixIcon: Icon(Icons.call),
                      ),
                    ),
                    Spacer(flex: 1),
                    TextFormField(
                      keyboardType: TextInputType.streetAddress,
                      controller: _address,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'fill this field';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Address',
                        labelText: 'Address',
                        suffixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    Spacer(flex: 1),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _gstNo,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'fill this field';
                        }
                      },
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: 'GST No. (15 letters)',
                        labelText: 'GST No.',
                        suffixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    Spacer(flex: 1),
                    ElevatedButton(
                      onPressed: _onPressSubmit,
                      child: Text('continue'),
                    ),
                    Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
