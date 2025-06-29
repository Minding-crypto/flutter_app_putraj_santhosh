import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instaclone/login_screen.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Account'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AccountPage()));
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Contact Support'),
                  onTap: () {
                    _launchEmail();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Buy Credits'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BuyCreditsPage()));
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
  onPressed: () async {
    final Uri url = Uri.parse('https://ratemeappr.github.io/RateMe/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  },
  child: const Text('Privacy Policy'),
),
          
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ratemeappr@gmail.com',
      query: 'subject=Support Request&body=Please describe your issue here.',
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      print(e);
    }
  }
}

/*void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ratemeappr@gmail.com',
      query: 'subject=Support Request&body=Please describe your issue here.',
    );

    try {
      // Correct usage of launchUrl function
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
    }
  }
}*/

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Center(
        child: Text('About Page'),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: const Center(
        child: Text('Help Page'),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  FirebaseStorage storage = FirebaseStorage.instance;

Future<void> _deleteAccount(BuildContext context) async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user's uploaded images
      await _deleteUserImages(user.uid);

      // Delete user's comments and likes
      await _deleteUserCommentsAndLikes(user.uid);

      // Delete user data from Firestore
      await _firestore.collection('usernames').doc(user.uid).delete();

      // Delete user authentication
      await user.delete();

      // Sign out from Google (if using Google Sign-In)
      await _googleSignIn.signOut();

      // Clear shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear any other cached data
      await MySharedPreferences().clearCache();

      // Navigate to welcome screen
      Navigator.pushNamedAndRemoveUntil(
          context, 'welcome_screen', (route) => false);
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error during account deletion: $error'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}

Future<void> _deleteUserImages(String userId) async {
  try {
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    for (var file in allFiles) {
      try {
        final FullMetadata fileMeta = await file.getMetadata();
        final String uploadedByUid = fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';

        if (uploadedByUid == userId) {
          // Delete the file from Storage
          await file.delete();

          // Delete associated comments
          await _deleteCommentsForImage(file.fullPath);

          // Delete associated likes
          await _deleteLikesForImage(file.fullPath);

          // Delete associated ratings
          await _deleteRatingsForImage(file.fullPath);

          print('Deleted post: ${file.fullPath}');
        }
      } catch (e) {
        print('Error processing file ${file.fullPath}: $e');
      }
    }
  } catch (e) {
    print('Error in _deleteUserImages: $e');
    // You might want to rethrow this error or handle it according to your app's error handling strategy
  }
}

Future<void> _deleteUserCommentsAndLikes(String userId) async {
  // Delete user's comments
  final QuerySnapshot commentQuery = await _firestore
      .collection('comments')
      .where('uploaded_by_uid', isEqualTo: userId)
      .get();

  for (var doc in commentQuery.docs) {
    await doc.reference.delete();
  }

  // Delete user's likes
  // Assuming likes are stored in a 'likes' collection with a 'user_id' field
  final QuerySnapshot likeQuery = await _firestore
      .collection('likes')
      .where('user_id', isEqualTo: userId)
      .get();

  for (var doc in likeQuery.docs) {
    await doc.reference.delete();
  }
}

Future<void> _deleteCommentsForImage(String imagePath) async {
  final QuerySnapshot commentQuery = await _firestore
      .collection('comments')
      .where('image_path', isEqualTo: imagePath)
      .get();

  for (var doc in commentQuery.docs) {
    await doc.reference.delete();
  }
}

Future<void> _deleteLikesForImage(String imagePath) async {
  // Assuming likes are stored in a 'likes' collection with an 'image_path' field
  final QuerySnapshot likeQuery = await _firestore
      .collection('likes')
      .where('image_path', isEqualTo: imagePath)
      .get();

  for (var doc in likeQuery.docs) {
    await doc.reference.delete();
  }
}

Future<void> _deleteRatingsForImage(String imagePath) async {
  // Assuming ratings are stored in a 'ratings' collection with an 'image_path' field
  final QuerySnapshot ratingQuery = await _firestore
      .collection('ratings')
      .where('image_path', isEqualTo: imagePath)
      .get();

  for (var doc in ratingQuery.docs) {
    await doc.reference.delete();
  }
}

  void _showReAuthenticationDialog(BuildContext context) {
  // Implement a dialog to get user's credentials and re-authenticate
  // This is a placeholder and should be implemented based on your app's UI
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Re-authentication Required'),
        content: Text('Please log in again to delete your account.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen or show login dialog
            },
          ),
        ],
      );
    },
  );
}

  Future<void> _logOff(BuildContext context) async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from Google (if using Google Sign-In)
      await _googleSignIn.signOut();
      
      // Clear shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Clear any other cached data (assuming you have a MySharedPreferences class)
      await MySharedPreferences().clearCache();
      
      // Navigate to welcome screen
      Navigator.pushNamedAndRemoveUntil(
          context, 'welcome_screen', (route) => false);
    } catch (error) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error during log off: $error'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 280,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Account"),
                        content: const Text(
                            "Are you sure you want to delete your account?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Delete"),
                            onPressed: () {
                              _deleteAccount(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Delete Account',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              width: 280,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(150, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Log Off"),
                        content:
                            const Text("Are you sure you want to log off?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Log Off"),
                            onPressed: () {
                              _logOff(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Log Off',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Center(
        child: Text('Privacy Policy Page'),
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: const Center(
        child: Text('Terms and Conditions Page'),
      ),
    );
  }
}
