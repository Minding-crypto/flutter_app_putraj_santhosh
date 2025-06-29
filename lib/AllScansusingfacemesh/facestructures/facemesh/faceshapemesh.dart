import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/face/faceshaperesults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Faceshapemesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Faceshapemesh({super.key, required this.imageFile});

  @override
  FaceshapemeshState createState() => FaceshapemeshState();
}

class FaceshapemeshState extends State<Faceshapemesh> {
  List<FaceMeshPoint>? _faceMeshPoints;
  FaceMeshDetector? faceMeshDetector;
  int _userCredits = 0;

  @override
  void initState() {
    super.initState();
    _initializeFaceMeshDetector();
     _fetchUserCredits().then((_) {
      // Process image after fetching credits
      _processImage(widget.imageFile);
    });
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
          MaterialPageRoute(builder: (context) => const BuyCreditsPage()),
        );
      }
    }
  }

  void _initializeFaceMeshDetector() {
    faceMeshDetector?.close();
    faceMeshDetector =
        FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
  }

 Future<void> _processImage(File imageFile) async {
    if (_userCredits < 10) {
      // Navigate to BuyCreditsPage if credits are insufficient
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BuyCreditsPage()),
      );
      return; // Exit the function to prevent further processing
    }
// Load ui.Image
    setState(() {});

    // Now detect face mesh with delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectFaceMeshWithDelay(imageFile);
    });
  }


  Future<void> _detectFaceMeshWithDelay(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faceMeshes = await faceMeshDetector!.processImage(inputImage);

    setState(() {
      _faceMeshPoints = faceMeshes.isNotEmpty ? faceMeshes.first.points : null;
    });

    // Print coordinates of left and right eye points
    if (_faceMeshPoints != null) {
      _analyzeFaceShape();
    } else {
      // Show a snackbar or dialog and navigate back if no face is detected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(child: Text('No face detected', style: TextStyle(fontSize: 20))),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 24.0),
          duration: const Duration(seconds: 4),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }

    // Delay for 1 second before showing face mesh
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
      });
    });
  }

  void _analyzeFaceShape() {
    if (_faceMeshPoints == null) return;

    // Define key facial points
    const foreheadIndex = 10;
    const chinIndex = 152;
    const leftCheekboneIndex = 234;
    const rightCheekboneIndex = 454;
    const leftJawIndex = 234;
    const rightJawIndex = 454;

    if ([
      foreheadIndex,
      chinIndex,
      leftCheekboneIndex,
      rightCheekboneIndex,
      leftJawIndex,
      rightJawIndex
    ].every((index) => index < _faceMeshPoints!.length)) {
      var foreheadPoint = _faceMeshPoints![foreheadIndex];
      var chinPoint = _faceMeshPoints![chinIndex];
      var leftCheekbonePoint = _faceMeshPoints![leftCheekboneIndex];
      var rightCheekbonePoint = _faceMeshPoints![rightCheekboneIndex];
      var leftJawPoint = _faceMeshPoints![leftJawIndex];
      var rightJawPoint = _faceMeshPoints![rightJawIndex];

      double faceHeight = sqrt(pow(foreheadPoint.x - chinPoint.x, 2) +
          pow(foreheadPoint.y - chinPoint.y, 2));
      double faceWidth = sqrt(
          pow(leftCheekbonePoint.x - rightCheekbonePoint.x, 2) +
              pow(leftCheekbonePoint.y - rightCheekbonePoint.y, 2));
      double jawWidth = sqrt(pow(leftJawPoint.x - rightJawPoint.x, 2) +
          pow(leftJawPoint.y - rightJawPoint.y, 2));

      String faceShape = _determineFaceShape(faceWidth, faceHeight, jawWidth);


       _deductCredits(10);
 WidgetsBinding.instance.addPostFrameCallback((_) {
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Faceshaperesults(
            image: widget.imageFile,
            results: 'Face Shape: $faceShape',
          ),
          ),
        );
      });
    }
  }

  
  String _determineFaceShape(
      double faceWidth, double faceHeight, double jawWidth) {
    double widthToHeightRatio = faceWidth / faceHeight;
    double jawToFaceWidthRatio = jawWidth / faceWidth;

    if (jawToFaceWidthRatio == 1.0) {
      if (widthToHeightRatio >= 0.85) {
        return "Round";
      } else if (widthToHeightRatio >= 0.81 && widthToHeightRatio < 0.84) {
        return "Diamond";
      } else if (widthToHeightRatio >= 0.79 && widthToHeightRatio < 0.81) {
        return "Heart";
      } else {
        return "Oval"; //0.81(diamond) 0.80(oval), 0.79(heart),
      }
    } else if (jawToFaceWidthRatio > 0.8 && jawToFaceWidthRatio < 1.0) {
      if (widthToHeightRatio >= 0.8) {
        return "Square";
      } else if (widthToHeightRatio < 0.8) {
        return "Oblong";
      }
    }

    return "Unknown";
  }


  @override
  void dispose() {
    faceMeshDetector?.close();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    // Returning an empty container since this page should be invisible
    return Container();
  }
}