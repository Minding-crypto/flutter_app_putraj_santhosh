import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instaclone/Recommendations/eyequalityrec.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class Eyequalityresults extends StatefulWidget {
  final String results;
  final dynamic image; // Accept both XFile and File

  const Eyequalityresults(
      {super.key, required this.results, required this.image});

  @override
  EyequalityresultsState createState() => EyequalityresultsState();
}

class EyequalityresultsState extends State<Eyequalityresults> {
  final _auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

 int _userCredits = 0;

 @override
  void initState() {
    super.initState();
    _fetchUserCredits();
  }

  Future<void> _fetchUserCredits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _userCredits = userData['credits'] ?? 0;
        });
      }
    }
  }

  Future<void> _deductCredits(int creditsToDeduct) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int newCredits = _userCredits - creditsToDeduct;
      if (newCredits >= 0) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'credits': newCredits});
          setState(() {
            _userCredits = newCredits;
          });
        } catch (e) {
        }
      } else {
        // Navigate to BuyCreditsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyCreditsPage()),
        );
      }
    }
  }

   Future<void> _uploadImage(dynamic image) async {
  
  // Convert XFile to File if necessary
  File imageFile = image is XFile ? File(image.path) : image;
  

  if (_userCredits < 5) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BuyCreditsPage()),
    );
    return;
  }

  final currentUser = _auth.currentUser;
  if (currentUser != null) {
    final String userUid = currentUser.uid;
    final String userEmail = currentUser.email ?? 'Unknown';
    String originalFileName = path.basename(imageFile.path);
    String fileExtension = path.extension(originalFileName);
    String fileName = path.basenameWithoutExtension(originalFileName);
    
    // Generate a unique file name by adding a timestamp
    String uniqueFileName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 50,
          ),
        );
      },
    );

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final String username = userData?['username'] as String? ?? 'Anonymous';

      final uploadTask = storage.ref(uniqueFileName).putFile(
        imageFile,
        SettableMetadata(
          customMetadata: {
            'uploaded_by_uid': userUid,
            'uploaded_by_email': userEmail,
            'description': 'Some description...',
          },
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      });

      final TaskSnapshot taskSnapshot = await uploadTask;

      final String fileUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'url': fileUrl,
        'uploaded_by_uid': userUid,
        'uploaded_by_email': userEmail,
        'description': 'Some description...',
        'original_file_name': originalFileName,
        'upload_time': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('usernames').doc(userUid).set({
        'username': username,
      });

      Navigator.of(context).pop(); // Dismiss loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );

      _deductCredits(5);
    } catch (error) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  } else {
  }
}


 Future<void> _showConfirmationDialog(dynamic image) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Upload Image'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to upload this image?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              _uploadImage(image); // Pass the original image
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Convert image to File if it's XFile
    final File imageFile = widget.image is XFile ? File(widget.image.path) : widget.image;

    // Split the results string into lines
    List<String> resultsList = widget.results.split(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(fontSize: 20),),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ), // Set the background color of the container
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 500, // Set the height of the Container
                            width: 400, // Set the width of the Container
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'Your Analysis',
                                  style: GoogleFonts.roboto(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color.fromARGB(255, 182, 182, 182), // Set the underline color to white
                                    decorationStyle: TextDecorationStyle.solid, // Set the underline style (optional)
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  child: Center(
                                      child: RichText(
                                          text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Eye Condition:  ',
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resultsList[0].split(': ')[0],
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ))),
                                  height: 60,
                                  width: 350,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 60,
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Eyequalityrec(results: widget.results),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                'View Recommendations  ➤',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 107, 33, 243)), // Set the background color here
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11.0), // Adjust the radius
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          width: 350,
                          child: ElevatedButton(
                          onPressed: () {
  // Pass the original widget.image to the confirmation dialog
  _showConfirmationDialog(widget.image);
},
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Upload Image',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.upload, // The upload icon
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                   const SizedBox(width: 20),
                                   Text(
                                    '(-5 Credits)',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      color: const Color.fromARGB(182, 255, 255, 255),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 107, 33, 243)), // Set the background color here
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11.0), // Adjust the radius
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
