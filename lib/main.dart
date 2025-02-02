import 'package:flutter/material.dart';
import 'package:todo_list/pages/splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'GoogleFonts.poppins().fontFamily',
      ),
      home: SplashScreen(),
    );
  }
}
