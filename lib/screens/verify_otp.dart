import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:surat_weavers_v3/main.dart';
import 'package:surat_weavers_v3/screens/home_screen.dart';

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen(
      {super.key,
      required this.companyName,
      required this.address,
      required this.gstno,
      required this.phoneNumber});
  final String companyName;
  final String address;
  final String gstno;
  final String phoneNumber;

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  TextEditingController otpController = TextEditingController();

  String _code = "";
  String signature = "{{ app signature }}";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  _verifyOTP() async {
    if (_code == "123123") {
      String _address = widget.address;
      String _gstno = widget.gstno;
      String _phoneNumber = widget.phoneNumber;
      String _companyName = widget.companyName;
      await FirebaseFirestore.instance
          .collection('rating')
          .doc(_gstno.toUpperCase())
          .set({
        'party_address': _address.trim().capitalize,
        'party_company_name': _companyName.capitalize,
        'party_gst_no': _gstno.toUpperCase(),
        'party_mobile': _phoneNumber.trim(),
        'avg rating': 0.0,
        'who rated': {},
        'comments': {},
      }).then(
        (value) {
          pageTransition(
              context: context, screen: HomeScreen(), replacement: true);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "due to sever error $_code , otp wont work , for now use 123123 as otp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PinFieldAutoFill(
                cursor: Cursor(
                    color: PhoenixThemeColor(),
                    width: 1.5,
                    height: 30,
                    enabled: true),
                decoration: UnderlineDecoration(
                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  colorBuilder:
                      FixedColorBuilder(Colors.black.withOpacity(0.3)),
                ),
                currentCode: _code,
                onCodeSubmitted: (code) {
                  log("code submmit called");
                },
                onCodeChanged: (code) {
                  _code = code!;
                  if (code.length == 6) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  }
                },
              ),
              ElevatedButton(onPressed: _verifyOTP, child: Text("Verify OTP")),
            ],
          ),
        ),
      ),
    );
  }
}
