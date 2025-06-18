import 'package:flutter/material.dart';
import 'package:flutter_09_kids_cam/Presentation/screen_cam.dart';
import 'package:flutter_09_kids_cam/Presentation/screen_picker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "KidsCam",
      initialRoute: '/',
      routes: {
        '/': (context) => const ScreenPicker(),
        '/cam': (context) => const ScreenCam(),
      },
    );
  }
}