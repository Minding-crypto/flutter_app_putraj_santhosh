import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/eyes/eyeshaperesults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Eyeshapemesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Eyeshapemesh({super.key, required this.imageFile});

  @override
  EyeshapemeshState createState() => EyeshapemeshState();
}

class EyeshapemeshState extends State<Eyeshapemesh> {
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
      _analyzeEyeShape();
    }else {
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

  void _analyzeEyeShape() {
    final leftEyeIndices = [
      33,
      133,
      160,
      159,
      158,
      157,
      173,
      153,
      154,
      155,
      144,
      145,
      153
    ];
    final rightEyeIndices = [
      362,
      263,
      387,
      386,
      385,
      384,
      398,
      382,
      381,
      380,
      374,
      373,
      390
    ];

    double calculateDistance(FaceMeshPoint a, FaceMeshPoint b) {
      return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
    }

    if (leftEyeIndices.every((index) => index < _faceMeshPoints!.length) &&
        rightEyeIndices.every((index) => index < _faceMeshPoints!.length)) {
      var leftEyeLeftCorner = _faceMeshPoints![leftEyeIndices[0]];
      var leftEyeRightCorner = _faceMeshPoints![leftEyeIndices[3]];
      var leftEyeTop = _faceMeshPoints![leftEyeIndices[1]];
      var leftEyeBottom = _faceMeshPoints![leftEyeIndices[5]];
      var leftEyeUpperLid = _faceMeshPoints![leftEyeIndices[4]];

      var rightEyeLeftCorner = _faceMeshPoints![rightEyeIndices[0]];
      var rightEyeRightCorner = _faceMeshPoints![rightEyeIndices[3]];
      var rightEyeTop = _faceMeshPoints![rightEyeIndices[1]];
      var rightEyeBottom = _faceMeshPoints![rightEyeIndices[5]];
      var rightEyeUpperLid = _faceMeshPoints![rightEyeIndices[4]];

      var leftEyeWidth =
          calculateDistance(leftEyeLeftCorner, leftEyeRightCorner);
      var leftEyeHeight = calculateDistance(leftEyeTop, leftEyeBottom);
      var rightEyeWidth =
          calculateDistance(rightEyeLeftCorner, rightEyeRightCorner);
      var rightEyeHeight = calculateDistance(rightEyeTop, rightEyeBottom);

      var leftEyeUpperLidHeight =
          calculateDistance(leftEyeTop, leftEyeUpperLid);
      var rightEyeUpperLidHeight =
          calculateDistance(rightEyeTop, rightEyeUpperLid);

      String analyzeEyeShape(double width, double height) {
        if (width / height > 1.5) {
          return "Deep-set Eyes";
        } else if (width / height > 1.2) {
          return "Round Eyes";
        } else {
          return "Almond Eyes";
        }
      }

      String analyzeEyelidShape(double upperLidHeight, double height) {
        return upperLidHeight / height < 0.2 ? "Monolid" : "Hooded";
      }

      String leftEyeShape = analyzeEyeShape(leftEyeWidth, leftEyeHeight);
      String rightEyeShape = analyzeEyeShape(rightEyeWidth, rightEyeHeight);

      analyzeEyelidShape(leftEyeUpperLidHeight, leftEyeHeight);
      analyzeEyelidShape(rightEyeUpperLidHeight, rightEyeHeight);

     // print('Left Eyelid Shape: $leftEyelidShape');
     // print('Right Eyelid Shape: $rightEyelidShape');

      _deductCredits(10);


  WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Eyeshaperesults(
            image: widget.imageFile,
            results: 'Left Eye Shape: $leftEyeShape, Right Eye Shape: $rightEyeShape',
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