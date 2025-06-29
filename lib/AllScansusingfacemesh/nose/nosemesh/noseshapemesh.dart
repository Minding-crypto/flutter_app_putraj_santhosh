import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/noseresults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Noseshapemesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Noseshapemesh({super.key, required this.imageFile});

  @override
  NoseshapemeshState createState() => NoseshapemeshState();
}

class NoseshapemeshState extends State<Noseshapemesh> {
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

    // Analyze nose shape if face mesh is detected
    if (_faceMeshPoints != null) {
      _analyzeNoseShape();
    } else {
      // Show a snackbar or dialog and navigate back if no face is detected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
              child: Text('No face detected', style: TextStyle(fontSize: 20))),
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

  void _analyzeNoseShape() {
    // Indices for the nose based on the face mesh model
    final noseIndices = [1, 2, 97, 98, 327, 294, 39, 165, 21, 71];

    if (noseIndices.every((index) => index < _faceMeshPoints!.length)) {
      var tip = _faceMeshPoints![noseIndices[0]];
      var leftNostril = _faceMeshPoints![noseIndices[2]];
      var rightNostril = _faceMeshPoints![noseIndices[5]];
      var bridgeTop = _faceMeshPoints![noseIndices[1]];
      var nostrilTopLeft = _faceMeshPoints![noseIndices[6]];
      var nostrilTopRight = _faceMeshPoints![noseIndices[7]];

      // Calculate the scaling factor based on the average eye-to-eye distance
      double leftEye = _faceMeshPoints![263].x;
      double rightEye = _faceMeshPoints![362].x;
      double eyeDistance = (rightEye - leftEye).abs();
      double averageEyeDistance = 64.0; // Average eye-to-eye distance in mm
      double scalingFactor = averageEyeDistance / eyeDistance;

      // Scale the coordinate values using the scaling factor
      tip = _scalePoint(tip, scalingFactor);
      leftNostril = _scalePoint(leftNostril, scalingFactor);
      rightNostril = _scalePoint(rightNostril, scalingFactor);
      bridgeTop = _scalePoint(bridgeTop, scalingFactor);
      nostrilTopLeft = _scalePoint(nostrilTopLeft, scalingFactor);
      nostrilTopRight = _scalePoint(nostrilTopRight, scalingFactor);

      double noseWidth = (leftNostril.x - rightNostril.x).abs();
      double noseHeight = (tip.y - bridgeTop.y).abs();


      double widthToHeightRatio = noseWidth / noseHeight;

      String noseShape = analyzeNoseShape(widthToHeightRatio);
      String noseshape2 = analyzeNoseShapes(noseWidth);

      _deductCredits(10);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Noseresults(
              image: widget.imageFile,
              results: 'Nose Shape: $noseShape and $noseshape2',
            ),
          ),
        );
      });
    }
  }

  FaceMeshPoint _scalePoint(FaceMeshPoint point, double scalingFactor) {
    return FaceMeshPoint(
      index: point.index,
      x: point.x * scalingFactor,
      y: point.y * scalingFactor,
      z: point.z * scalingFactor,
    );
  }

  String analyzeNoseShape(double widthToHeightRatio) {
    if (widthToHeightRatio > 6.6) {
      return "Downturned";
    } else if (widthToHeightRatio < 4.45) {
      return "Upturned";
    } else {
      return "Straight";
    }
  }

 String analyzeNoseShapes(double noseWidth) {
    if (noseWidth < 64.0) {
      return "Narrow nasal structure";
    } else if (noseWidth >= 64.0 && noseWidth <= 67.5) {
      return "Medium nasal structure";
    } else {
      return "Wide nasal structure";
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
