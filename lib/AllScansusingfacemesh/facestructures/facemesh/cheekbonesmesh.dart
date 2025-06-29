import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/face/cheekbonesresults.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Cheekbonesmesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Cheekbonesmesh({super.key, required this.imageFile});

  @override
  CheekbonesmeshState createState() => CheekbonesmeshState();
}

class CheekbonesmeshState extends State<Cheekbonesmesh> {
  List<FaceMeshPoint>? _faceMeshPoints;
  FaceMeshDetector? faceMeshDetector;
  int _userCredits = 0;
  bool _isAnalyzing = false;

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
          MaterialPageRoute(builder: (context) => BuyCreditsPage()),
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
        MaterialPageRoute(builder: (context) => BuyCreditsPage()),
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
    setState(() {
      _isAnalyzing = true; // Set _isAnalyzing to true before starting analysis
    });
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faceMeshes = await faceMeshDetector!.processImage(inputImage);

    setState(() {
      _faceMeshPoints = faceMeshes.isNotEmpty ? faceMeshes.first.points : null;
      _isAnalyzing = false;
    });

    // Print coordinates of left and right eye points
    if (_faceMeshPoints != null) {
      _analyzeCheekbones();
      ;
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

  void _analyzeCheekbones() {
    const leftCheekboneIndex = 234; // Point on left cheekbone
    const rightCheekboneIndex = 454; // Point on right cheekbone
    const leftEyeIndex = 159; // Point under left eye
    const rightEyeIndex = 386; // Point under right eye
    const chinIndex = 152; // Point on the chin


    if (_faceMeshPoints != null &&
        leftCheekboneIndex < _faceMeshPoints!.length &&
        rightCheekboneIndex < _faceMeshPoints!.length &&
        leftEyeIndex < _faceMeshPoints!.length &&
        rightEyeIndex < _faceMeshPoints!.length &&
        chinIndex < _faceMeshPoints!.length) {
      var leftCheekbone = _faceMeshPoints![leftCheekboneIndex];
      var rightCheekbone = _faceMeshPoints![rightCheekboneIndex];
      var leftEye = _faceMeshPoints![leftEyeIndex];
      var rightEye = _faceMeshPoints![rightEyeIndex];
      var chin = _faceMeshPoints![chinIndex];

      var leftCheekboneHeight = leftCheekbone.y - leftEye.y;
      var rightCheekboneHeight = rightCheekbone.y - rightEye.y;
      var leftFaceHeight = chin.y - leftEye.y;
      var rightFaceHeight = chin.y - rightEye.y;

      String analyzeCheekboneProminence(
          double cheekboneHeight, double faceHeight) {
        double ratio = cheekboneHeight / faceHeight;
        if (ratio < 0.15) {
          return "Very High";
        } else if (ratio < 0.18) {
          return "High";
        } else if (ratio < 0.3) {
          return "Average";
        } else {
          return "Low";
        }
      }

      String leftCheekboneProminence =
          analyzeCheekboneProminence(leftCheekboneHeight, leftFaceHeight);
      String rightCheekboneProminence =
          analyzeCheekboneProminence(rightCheekboneHeight, rightFaceHeight);


      _deductCredits(10);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Cheekbonesresults(
              image: widget.imageFile,
              results:
                  'Left Cheekbone Prominence: $leftCheekboneProminence, Right Cheekbone Prominence: $rightCheekboneProminence',
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
    if (_isAnalyzing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analyzing...'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: 
        Center(
          
          child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 50,
            ),
        ),
      );
    } else {
      // Returning an empty container since this page should be invisible
      return Container();
    }
  }
}
