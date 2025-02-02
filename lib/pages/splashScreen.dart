import 'package:flutter/material.dart';
import 'package:todo_list/pages/toDoScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => TodoScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color remains white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splash_logo.png', // Path to your asset image
              width: 100, // Set the width of the image
              height: 100, // Set the height of the image
            ),
            SizedBox(height: 20),
            Text("Let's Do it!",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black, // Changed to black
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
