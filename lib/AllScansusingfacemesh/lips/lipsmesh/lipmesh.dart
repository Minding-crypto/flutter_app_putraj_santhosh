import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/lipsresults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Lipmesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Lipmesh({super.key, required this.imageFile});

  @override
  LipmeshState createState() => LipmeshState();
}

class LipmeshState extends State<Lipmesh> {
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

    if (_faceMeshPoints != null) {
      _analyzeLipShape();
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

      Future.delayed(const Duration(milliseconds: 1), () {
        Navigator.pop(context);
      });
    }

    // Delay for 1 second before showing face mesh
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
      });
    });
  }

  void _analyzeLipShape() {
    const upperLipTopIndex = 0; // Point on the upper lip top
    const lowerLipBottomIndex = 17; // Point on the lower lip bottom
    const leftLipCornerIndex = 61; // Point on the left corner of the lip
    const rightLipCornerIndex = 291; // Point on the right corner of the lip
    const upperLipBottomIndex = 13; // Point on the upper lip bottom
    const lowerLipTopIndex = 14; // Point on the lower lip top

    double calculateDistance(FaceMeshPoint a, FaceMeshPoint b) {
      return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
    }

    if (_faceMeshPoints != null &&
        upperLipTopIndex < _faceMeshPoints!.length &&
        lowerLipBottomIndex < _faceMeshPoints!.length &&
        leftLipCornerIndex < _faceMeshPoints!.length &&
        rightLipCornerIndex < _faceMeshPoints!.length &&
        upperLipBottomIndex < _faceMeshPoints!.length &&
        lowerLipTopIndex < _faceMeshPoints!.length) {
      var upperLipTop = _faceMeshPoints![upperLipTopIndex];
      var lowerLipBottom = _faceMeshPoints![lowerLipBottomIndex];
      var leftLipCorner = _faceMeshPoints![leftLipCornerIndex];
      var rightLipCorner = _faceMeshPoints![rightLipCornerIndex];
      var upperLipBottom = _faceMeshPoints![upperLipBottomIndex];
      var lowerLipTop = _faceMeshPoints![lowerLipTopIndex];

      var lipWidth = calculateDistance(leftLipCorner, rightLipCorner);
      var upperLipHeight = calculateDistance(upperLipTop, upperLipBottom);
      var lowerLipHeight = calculateDistance(lowerLipTop, lowerLipBottom);

      double upperRatio = upperLipHeight / lipWidth;
      double lowerRatio = lowerLipHeight / lipWidth;
      double totalHeight = upperLipHeight + lowerLipHeight;
      double heightToWidthRatio = totalHeight / lipWidth;

      String analyzeLipShape(
          double width, double upperHeight, double lowerHeight) {
        if (upperRatio < 0.2 && lowerRatio < 0.2) {
          return "Thin";
        } else if (upperRatio > 0.3 && lowerRatio > 0.3) {
          return "Full";
        } else if (upperRatio / lowerRatio > 1.2) {
          return "Heart-shaped";
        } else if (heightToWidthRatio < 0.4) {
          return "Wide";
        } else if (upperRatio > 0.25 && lowerRatio < 0.2) {
          return "Heavy Upper Lip";
        } else if (lowerRatio > 0.25 && upperRatio < 0.2) {
          return "Heavy Lower Lip";
        } else if (heightToWidthRatio > 0.45) {
          // Condition for very big lips
          return "Large Full Lips";
        } else {
          return "Round Lips";
        }
      }

      String lipShape =
          analyzeLipShape(lipWidth, upperLipHeight, lowerLipHeight);


      // If the scan is successful, deduct 10 credits
      _deductCredits(10);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Lipsresults(
              image: widget.imageFile,
              results: 'Lip Shape: $lipShape',
            ),
          ),
        );
      });
    }
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
