import 'package:campusapp/pages/login_page.dart';
//import 'package:campusapp/pages/study_page.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // home: StudyPage(),
      
    );
  }
}

