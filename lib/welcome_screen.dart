import 'package:flutter/material.dart';
import 'rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('assets/image (2) (1) (1).png'), // Replace with your logo asset
              ),
            ),
           
           
            RoundedButton(
              colour: const Color.fromARGB(255, 79, 52, 255),
              title: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, 'login_screen');
              },
            ),
            RoundedButton(
              colour: const Color.fromARGB(255, 124, 53, 255),
              title: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, 'registration_screen');
              },
            ),
          ],
        ),
      ),
    );
  }
}