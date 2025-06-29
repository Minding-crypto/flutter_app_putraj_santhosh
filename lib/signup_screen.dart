// ignore_for_file: duplicate_import, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rounded_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import the loading animation package
import 'login_screen.dart'; // Import the login screen
import 'package:sign_in_button/sign_in_button.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instaclone/signup_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'rounded_button.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:material_symbols_icons/symbols.dart';

// Code for designing the UI of our text field where the user writes his email id or password

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

class Validations {
  static String? validateName(String? value) {
    if (value!.isEmpty) return 'Username is Required.';
    if (value.length > 12) return 'Username cannot be more than 15 characters.';
    if (value.length < 3) return 'Username should be more than 2 characters.';

    final RegExp nameExp = new RegExp(r'^[A-Za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
  }

  static String? validateEmail(String? value, [bool isRequired = true]) {
    if (value!.isEmpty && isRequired) return 'Email is required.';
    final RegExp nameExp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequired) return 'Invalid email address';
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty || value.length < 6)
      return 'Please enter a valid password (min 6 characters).';
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Add this line
  late String email;
  late String password;
  late String username;
  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
      reverseDuration: const Duration(seconds: 100),
    )..repeat();
  }

  void checkCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (user != null || isLoggedIn) {
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
          'Registration',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Stack(
          children: [
            // AnimatedBackground(controller: _controller), // Add the animated background
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        username = value;
                      },
                      validator: Validations.validateName,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Choose a username',
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.7)),
                        fillColor: const Color.fromRGBO(63, 70, 85, 1),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10.0),
                        errorStyle: const TextStyle(
                          // Add this line to customize error text style
                          color: Color.fromARGB(255, 162, 11, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        email = value;
                      },
                      validator: Validations.validateEmail,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.7)),
                        fillColor: const Color.fromRGBO(63, 70, 85, 1),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10.0),
                        errorStyle: const TextStyle(
                          // Add this line to customize error text style
                          color: Color.fromARGB(255, 162, 11, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                      obscureText: true,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: Validations.validatePassword,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your Password',
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.7)),
                        fillColor: const Color.fromRGBO(63, 70, 85, 1),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10.0),
                        errorStyle: const TextStyle(
                          // Add this line to customize error text style
                          color: Color.fromARGB(255, 162, 11, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoundedButton(
                        colour: const Color.fromARGB(255, 124, 53, 255),
                        title: 'Register',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              showSpinner = true;
                            });
                            try {
                              if (username == null || username.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a username.',
                                    ),
                                  ),
                                );
                              } else {
                                final isUsernameTaken =
                                    await isUsernameAlreadyTaken(username);
                                if (isUsernameTaken) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'This username is already taken. Please choose a different username.',
                                      ),
                                    ),
                                  );
                                } else {
                                  UserCredential userCredential = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password);
                                  if (userCredential.user != null) {
                                    await _firestore
                                        .collection('users')
                                        .doc(userCredential.user!.uid)
                                        .set({
                                      'email': email,
                                      'username': username,
                                    });
                                    await MySharedPreferences().clearCache();

                                    // Set isLoggedIn flag
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', true);

                                    Navigator.pushReplacementNamed(
                                        context, 'home_screen',
                                        arguments: username);
                                  }
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This email is already registered. Please use login instead.',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Registration failed. Please try again later.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Registration failed. Please try again later.',
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        },
                      ),
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

                    // SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SignInButton(
                        Buttons.google,
                        onPressed: _handleSignIn,
                        text: 'Sign up with Google',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ), // Add some space between Register button and TextButton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
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
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Log in",
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    try {
      await googleSignIn.signOut(); // Sign out before signing in
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        _handleSignInSuccess(account);
      } else {
        // Handle sign-in failure
      }
    } catch (error) {}
  }

  void _handleSignInSuccess(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user is already registered
        final QuerySnapshot<Map<String, dynamic>> result = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        final List<DocumentSnapshot<Map<String, dynamic>>> documents =
            result.docs;
        if (documents.isEmpty) {
          // User is not registered, add them to the database
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'username':
                account.displayName, // Use the Google display name as username
          });
        }
        await MySharedPreferences().clearCache();

        // Set isLoggedIn flag
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacementNamed(context, 'home_screen');
      }
    } catch (error) {
      print('Error during sign-in success handling: $error');
    }
  }

  Future<bool> isUsernameAlreadyTaken(String username) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents = result.docs;
    return documents.isNotEmpty;
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
        final expiration =
            DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
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
        return MapEntry(
            key,
            value.map((v) {
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
        return MapEntry(
            key,
            value.map((v) {
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
              image:
                  const AssetImage('assets/Screenshot 2024-05-12 203540.png'),
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
