import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:surat_weavers_v3/export_data.dart';
import 'package:surat_weavers_v3/screens/registration_screen.dart';
import 'package:surat_weavers_v3/screens/splash_screen.dart';
import 'package:surat_weavers_v3/test.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: "AIzaSyAQx9L-5EYCB4HbM5xrE9ClK4pUPLZX8nE",
              appId: "1:152669265070:android:fdabf9bcf41bf46be7e13f",
              messagingSenderId: "152669265070",
              projectId: "surat-weavers-v3"))
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

pageTransition(
    {required context, required Widget screen, required bool replacement}) {
  replacement
      ? Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => screen,
          ))
      : Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PhoenixThemeColor(), width: 2),
                  borderRadius: BorderRadius.circular(10)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            primaryColor: PhoenixThemeColor(),
            colorScheme: ColorScheme.fromSeed(seedColor: PhoenixThemeColor()),
            useMaterial3: true,
          ),
          home: SplashScreen(),
          // home: ExportScreen(),
        );
      },
    );
  }
}

Color PhoenixThemeColor() => Color(0xff036274);
