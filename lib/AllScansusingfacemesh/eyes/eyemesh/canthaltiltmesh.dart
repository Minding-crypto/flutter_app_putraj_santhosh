import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/eyes/canthaltiltresults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Canthaltiltmesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Canthaltiltmesh({super.key, required this.imageFile});

  @override
  CanthaltiltmeshState createState() => CanthaltiltmeshState();
}

class CanthaltiltmeshState extends State<Canthaltiltmesh> {
  List<FaceMeshPoint>? _faceMeshPoints;
  FaceMeshDetector? faceMeshDetector;
  int _userCredits = 0;

  @override
  void initState() {
    super.initState();
    _initializeFaceMeshDetector();
    _fetchUserCredits().then((_) {
      if (_userCredits >= 10) {
        _processImage(widget.imageFile);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuyCreditsPage()),
        );
      }
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
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faceMeshes = await faceMeshDetector!.processImage(inputImage);

    setState(() {
      _faceMeshPoints = faceMeshes.isNotEmpty ? faceMeshes.first.points : null;
    });

    // Calculate canthal tilt if face mesh points are available
    if (_faceMeshPoints != null) {
      final leftEyeCanthalTilt = _calculateCanthalTiltForLeftEye();
      final rightEyeCanthalTilt = _calculateCanthalTiltForRightEye();

      // Deduct credits after successful scan
      await _deductCredits(10);

      // Navigate to the results page with the image and results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Canthaltiltresults(
            image: widget.imageFile,
            results:
                'Left Eye: $leftEyeCanthalTilt, Right Eye: $rightEyeCanthalTilt',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            child: Text('No face detected', style: TextStyle(fontSize: 20)),
          ),
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

  }

  String _calculateCanthalTiltForLeftEye() {
    final leftEyeIndices = [33, 243];

    if (leftEyeIndices[0] < _faceMeshPoints!.length &&
        leftEyeIndices[1] < _faceMeshPoints!.length) {
      var outerCorner = _faceMeshPoints![leftEyeIndices[1]];
      var innerCorner = _faceMeshPoints![leftEyeIndices[0]];


      // Calculate the canthal tilt
      var deltaX = outerCorner.x - innerCorner.x;
      var deltaY = outerCorner.y - innerCorner.y;
      var angle = atan2(deltaY, deltaX) * 180 / pi;

      String canthalTilt = angle > 6.5
          ? 'Positive'
          : angle < 2.5
              ? 'Negative'
              : 'Neutral';
      return canthalTilt;
    }
    return 'unknown';
  }

  String _calculateCanthalTiltForRightEye() {
    final rightEyeIndices = [362, 263]; // Corrected variable name

    if (rightEyeIndices[0] < _faceMeshPoints!.length &&
        rightEyeIndices[1] < _faceMeshPoints!.length) {
      var innerCorner = _faceMeshPoints![rightEyeIndices[0]]; // Inner corner
      var outerCorner = _faceMeshPoints![rightEyeIndices[1]]; // Outer corner


      // Calculate the canthal tilt
      var deltaX = outerCorner.x - innerCorner.x;
      var deltaY = outerCorner.y - innerCorner.y;
      var angle = atan2(deltaY, deltaX) * 180 / pi;

      // Ensure the angle is between -180 and 180 degrees
      if (angle < 0) {
        angle += 360;
      }

      // Adjust the angle to the range of 0 to 180 degrees
      if (angle > 180) {
        angle = 360 - angle;
      }

      String canthalTilt = angle > 6.5
          ? 'Positive'
          : angle < 2.5
              ? 'Negative'
              : 'Neutral';
      return canthalTilt;
    }
    return 'unknown';
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
