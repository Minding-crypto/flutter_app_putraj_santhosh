import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instaclone/image.dart';
import 'package:instaclone/personalprofile..dart';
import 'package:instaclone/rankingpage.dart';
import 'package:instaclone/scans.dart';
import 'package:instaclone/settings.dart';
import 'package:instaclone/user_profile.dart';
import 'package:instaclone/welcome_screen.dart';
import 'package:instaclone/signup_screen.dart';
import 'package:instaclone/login_screen.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDHnXU2KO_kUGDgZfQ1wBaLGDyYgNweFRU",
            appId: "1:431537366078:android:6693244e28a025d69c1d6f",
            messagingSenderId: "431537366078",
            projectId: "social-media-app-8ba42",
            storageBucket: "social-media-app-8ba42.appspot.com",
          ),
        )
      : await Firebase.initializeApp();


        await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
   // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),  // replace with your site key if needed

    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.playIntegrity, // or AndroidProvider.safetyNet

    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    //appleProvider: AppleProvider.appAttest,  // or AppleProvider.deviceCheck
  );

  User? user = FirebaseAuth.instance.currentUser;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn || user != null));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     initialRoute: isLoggedIn ? 'home_screen' : 'welcome_screen',
      onGenerateRoute: (settings) {
        if (settings.name == UserProfile.routeName) {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;
          final String userId = args['userId'] as String;
          return MaterialPageRoute(
              builder: (context) => UserProfile(userId: userId));
        }
        switch (settings.name) {
          case 'welcome_screen':
            return MaterialPageRoute(builder: (context) => const WelcomeScreen());
          case 'registration_screen':
            return MaterialPageRoute(
                builder: (context) => const RegistrationScreen());
          case 'login_screen':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case 'home_screen':
            return MaterialPageRoute(builder: (context) => const fakepage());
          case 'fake_screen':
            return MaterialPageRoute(builder: (context) => const fakepage());
              case 'settings':
            return MaterialPageRoute(builder: (context) => const SettingsPage());
          default:
            return MaterialPageRoute(builder: (context) => const fakepage());
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class fakepage extends StatefulWidget {
  const fakepage({super.key});

  @override
  fakepageState createState() => fakepageState();
}

class fakepageState extends State<fakepage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const Scans(),
    const HomeScreen(),
    const personalprofile(),
    const TopPostsPage(),
  ];

  Color _iconColor(int index) {
    return index == _currentIndex ? Colors.white : Colors.grey;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.green,
          primaryColor: Colors.red,
          textTheme: Theme.of(context).textTheme.copyWith(),
        ),
        child: BottomAppBar(
          color: Colors.black,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
             
              IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 25.0,
                ),
                color: _iconColor(1),
                onPressed: () {
                  onTabTapped(1);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_box_outlined,
                  size: 25.0,
                ),
                color: _iconColor(0),
                onPressed: () {
                  onTabTapped(0);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  size: 25.0,
                ),
                color: _iconColor(3),
                onPressed: () {
                  onTabTapped(3);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  size: 25.0,
                ),
                color: _iconColor(2),
                onPressed: () {
                  onTabTapped(2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
