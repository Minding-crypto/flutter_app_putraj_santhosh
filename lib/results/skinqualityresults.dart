import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instaclone/Recommendations/skinqualityrec.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Skinqualityresults extends StatefulWidget {
  final String results;
  final Uint8List image;

  const Skinqualityresults(
      {super.key, required this.results, required this.image});

  @override
  SkinqualityresultsState createState() => SkinqualityresultsState();
}

class SkinqualityresultsState extends State<Skinqualityresults> {
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


  Future<void> _uploadImage(Uint8List imageData) async {
       if (_userCredits < 5) {
      // Navigate to BuyCreditsPage if credits are insufficient
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BuyCreditsPage()),
      );
      return; // Exit the function to prevent further processing
    }
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final String userUid = currentUser.uid;
      final String userEmail = currentUser.email ?? 'Unknown';
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

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
        // Fetch the username from the 'users' collection
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>?;
        final String username = userData?['username'] as String? ?? 'Anonymous';

        // Upload image
        final uploadTask = storage.ref(fileName).putData(
              imageData,
              SettableMetadata(
                customMetadata: {
                  'uploaded_by_uid': userUid,
                  'uploaded_by_email': userEmail,
                  'description': 'Some description...',
                },
              ),
            );

        // Listen for upload progress (optional)
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          // You can update a progress indicator here if you want
        });

        // Get the download URL of the uploaded image
        final TaskSnapshot taskSnapshot = await uploadTask;
        final String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Add post to Firestore
        await FirebaseFirestore.instance.collection('posts').add({
          'url': fileUrl,
          'uploaded_by_uid': userUid,
          'uploaded_by_email': userEmail,
          'description': 'Some description...',
        });

        // Store the username separately
        await FirebaseFirestore.instance
            .collection('usernames')
            .doc(userUid)
            .set({
          'username': username,
        });

        // Dismiss loading indicator
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } on FirebaseException catch (error) {
        // Dismiss loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.message}')),
        );
      } catch (error) {
        // Dismiss loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
      _deductCredits(5);
  }

  Future<void> _showConfirmationDialog(Uint8List imageData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _uploadImage(imageData); // Proceed with the upload
              },
            ),
          ],
        );
      },
    );
  }

 
 
 //THIS IS FOR CLASSES WITH NUMBERS LIKE ACNEX4
 String _getResultsText(String results) {
    if (results.isEmpty) {
      return 'Clear Skin';
    }
    final List<String> resultList = results.split(', ');
    if (resultList.length == 1) {
      final List<String> parts = resultList[0].split('x');
      if (parts.length == 2) {
        final int count = int.parse(parts[1]);
        if (count <= 5) {
          return 'Clear Skin';
        }
      }
    }
    return results;

  }

   /*
   
 //THIS IS FOR CLASSES WITHout NUMBERS LIKE ACNE
    String _getResultsText(String results) {
    if (results.isEmpty) {
      return 'Clear Skin';
    }
    final List<String> resultList = results.split(', ');
    final List<String> cleanResults = [];

    for (String result in resultList) {
      final List<String> parts = result.split('x');
      if (parts.length == 2) {
        final int count = int.parse(parts[1]);
        if (count <= 5) {
          cleanResults.add(parts[0]);
        } else {
          cleanResults.add(result);
        }
      } else {
        cleanResults.add(result);
      }
    }

    if (cleanResults.length == 1 && int.parse(cleanResults[0].split('x')[1]) <= 5) {
      return 'Clear Skin';
    }

    return cleanResults.map((res) => res.split('x')[0]).join(', ');
  }*/

  @override
  Widget build(BuildContext context) {
    // Determine the results text
    String resultsText = _getResultsText(widget.results);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Results',
          style: TextStyle(fontSize: 20),
        ),
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
                                child: Image.memory(
                                  widget.image,
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
                                    decorationColor: const Color.fromARGB(
                                        255, 182, 182, 182), // Set the underline color to white
                                    decorationStyle: TextDecorationStyle
                                        .solid, // Set the underline style (optional)
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                            Container(
  width: 200,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(11),
    color: Colors.white,
  ),
  child: Center(
    child: Padding(
      padding: const EdgeInsets.all(8.0), // Optional: to add some padding inside the container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         Text(
  'Detected:',
  style: GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    decoration: TextDecoration.underline, // Underline the text
  ),
),

          ...resultsText.split(', ').map((result) => Padding(
            padding: const EdgeInsets.only(top: 4.0), // Optional: to add space between lines
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content of each row
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  result,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ),
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
                                  builder: (context) =>
                                      Skinqualityrec(results: widget.results),
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
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 107, 33, 243)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11.0),
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
                              // Show confirmation dialog
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
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 107, 33, 243)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11.0),
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