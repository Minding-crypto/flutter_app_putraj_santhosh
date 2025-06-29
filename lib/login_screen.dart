import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instaclone/personalprofile..dart';
import 'package:instaclone/signup_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rounded_button.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:material_symbols_icons/symbols.dart';
// ignore_for_file: duplicate_import, unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'rounded_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import the loading animation package
import 'login_screen.dart'; // Import the login screen
import 'package:sign_in_button/sign_in_button.dart';


//code for designing the UI of our text field where the user writes his email id or password

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
 enabledBorder: OutlineInputBorder(
   // borderSide: BorderSide(color: Color.fromARGB(255, 53, 0, 90), width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedBorder: OutlineInputBorder(
    //borderSide: BorderSide(color: Color.fromARGB(255, 72, 0, 99), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final _sharedPrefs = MySharedPreferences();

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late String email;
  late String password;
  bool showSpinner = false;
  late AnimationController _controller;
   final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Add this line
  
  late String username;

 @override
void initState() {
  super.initState();
  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  checkCurrentUser();
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 25),
    reverseDuration: const Duration(seconds: 100),
  )..repeat();

  // Adding event listener for when the user signs in with Google
  googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
    if (account != null) {
      _handleSignInSuccess(account);
    }
  });
}

void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Color.fromARGB(255, 255, 0, 0),
      duration: const Duration(seconds: 3),
    ),
  );
}


 Future<void> _clearCacheAndLogin() async {
  setState(() {
    showSpinner = true;
  });
  try {
    // Clear cached data
    await _sharedPrefs.clearCache();

    // Perform login logic
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = userCredential.user;

    if (user != null) {
      // Set isLoggedIn flag
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, 'home_screen');
    }
  } catch (e) {
    // Handle errors here
      _showErrorSnackBar('Error during login');
  } finally {
    setState(() {
      showSpinner = false;
    });
  }
}

 Future<void> _handleSignIn() async {
  setState(() {
    showSpinner = true;
  });
  try {
    await googleSignIn.signOut(); // Sign out before signing in
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      await _handleSignInSuccess(account); // Add await here
    } else {
      // Handle sign-in failure
       _showErrorSnackBar('Google sign-in aborted by user');
    }
  } catch (error) {
    _showErrorSnackBar('Error during Google sign-in');
  } finally {
    setState(() {
      showSpinner = false;
    });
  }
}

Future<void> _handleSignInSuccess(GoogleSignInAccount account) async {
  try {
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // Check if the user is already registered
      final QuerySnapshot<Map<String, dynamic>> result = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();
      final List<DocumentSnapshot<Map<String, dynamic>>> documents = result.docs;
      if (documents.isEmpty) {
        // User is not registered, add them to the database
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'username': account.displayName, // Use the Google display name as username
        });
      }
      await MySharedPreferences().clearCache();
      
      // Set isLoggedIn flag
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      Navigator.pushReplacementNamed(context, 'home_screen');
    }
  } catch (error) {
     _showErrorSnackBar('Error during login');
    // You might want to show an error message to the user here
  }
}

void checkCurrentUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // User is already signed in, navigate to home screen
    Navigator.pushReplacementNamed(context, 'home_screen');
  }
}



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor:
            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
         // AnimatedBackground(controller: _controller),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(
                         color: Color.fromRGBO(255, 255, 255, 0.7)),
                    fillColor: const Color.fromRGBO(63, 70, 85, 1),
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password.',
                    hintStyle: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.7)),
                    fillColor: const Color.fromRGBO(63, 70, 85, 1),
                    
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  
                    
                    child: RoundedButton(
  colour: const Color.fromARGB(255, 79, 52, 255),
  title: 'Log In',
  onPressed: _clearCacheAndLogin, // Use _clearCacheAndLogin as the onPressed callback
),
                    
                ),
                const SizedBox(
                  height: 8.0,
                ),
               Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      height: 1.0,
      width: 100.0, // Adjust the width as needed
      color: const Color.fromARGB(255, 255, 255, 255),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'or',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    Container(
      height: 1.0,
      width: 100.0, // Adjust the width as needed
      color: const Color.fromARGB(255, 255, 255, 255),
    ),
  ],
),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SignInButton(
                    Buttons.google,
                    onPressed: _handleSignIn,
                    //child: Text('Sign in with Google'),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
               Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      "Don't have an account? ",
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationScreen(),
          ),
        );
      },
      child: const Text(
        "Sign Up",
        style: TextStyle(
          color: Color.fromARGB(255, 140, 129, 255),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  ],
),

              ],
            ),
          ),
          if (showSpinner)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingAnimationWidget.twistingDots(
                  leftDotColor: const Color.fromARGB(255, 123, 123, 255),
                  rightDotColor: const Color(0xFFEA3799),
                  size: 70,
                ),
              ),
            ),
        ],
      ),
    );
  }


}

class MySharedPreferences {
  static const String _keyData = 'profileData';
  static const String _keyExpiration = 'profileExpirationTime';

  Future<void> saveData(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = data.map((map) {
      final jsonSafeMap = _convertToJson(map);
      return jsonEncode(jsonSafeMap);
    }).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyData, jsonString);

    // Set expiration to 1 hour from now (adjust as needed)
    final expirationTime = DateTime.now().add(const Duration(hours: 1));
    await prefs.setInt(_keyExpiration, expirationTime.millisecondsSinceEpoch);
  }

  Future<List<Map<String, dynamic>>?> getData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationTimestamp = prefs.getInt(_keyExpiration);
      if (expirationTimestamp != null) {
        final expiration = DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
        if (expiration.isAfter(DateTime.now())) {
          final cachedData = prefs.getString(_keyData);
          if (cachedData != null) {
            final List<dynamic> jsonList = jsonDecode(cachedData);
            return jsonList.map((jsonString) {
              final dynamic decodedData = jsonDecode(jsonString);
              if (decodedData is Map) {
                return _convertFromJson(decodedData.cast<String, dynamic>());
              }
              return <String, dynamic>{};
            }).toList();
          }
        }
      }
    } catch (e) {
      // Clear corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyData);
      await prefs.remove(_keyExpiration);
    }
    return null; // Data has expired, doesn't exist, or there was an error
  }

  Map<String, dynamic> _convertToJson(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      } else if (value is List) {
        return MapEntry(key, value.map((v) {
          if (v is Map) {
            return _convertToJson(v.cast<String, dynamic>());
          }
          return v;
        }).toList());
      } else if (value is Map) {
        return MapEntry(key, _convertToJson(value.cast<String, dynamic>()));
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _convertFromJson(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is String && value.contains('T')) {
        try {
          return MapEntry(key, DateTime.parse(value));
        } catch (_) {
          return MapEntry(key, value);
        }
      } else if (value is List) {
        return MapEntry(key, value.map((v) {
          if (v is Map) {
            return _convertFromJson(v.cast<String, dynamic>());
          }
          return v;
        }).toList());
      } else if (value is Map) {
        return MapEntry(key, _convertFromJson(value.cast<String, dynamic>()));
      }
      return MapEntry(key, value);
    });
  }
  Future<void> deleteCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyData);
    await prefs.remove(_keyExpiration);
  }
  Future<void> clearCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyData);
  await prefs.remove(_keyExpiration);
}
}


class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: const AssetImage('assets/Screenshot 2024-05-12 203540.png'),
              repeat: ImageRepeat.repeat,
              alignment: Alignment(
                controller.value,
                controller.value,
              ),
            ),
          ),
        );
      },
    );
  }
}
