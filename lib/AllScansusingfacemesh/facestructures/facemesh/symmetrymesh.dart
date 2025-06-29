import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/face/symmetryresults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Symmetrymesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Symmetrymesh({super.key, required this.imageFile});

  @override
  SymmetrymeshState createState() => SymmetrymeshState();
}

class SymmetrymeshState extends State<Symmetrymesh> {
  List<FaceMeshPoint>? _faceMeshPoints;
  FaceMeshDetector? faceMeshDetector;
  double? _symmetryPercentage;
  double? _eyeSymmetry;
  double? _noseSymmetry;
  double? _mouthSymmetry;
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
      _calculateSymmetry();
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

  FaceMeshPoint calculateMidPoint(FaceMeshPoint a, FaceMeshPoint b) {
    return FaceMeshPoint(
      index: -1,
      x: (a.x + b.x) / 2,
      y: (a.y + b.y) / 2,
      z: (a.z + b.z) / 2,
    );
  }

  void _calculateSymmetry() {
    if (_faceMeshPoints == null || _faceMeshPoints!.length < 3) return;

    // Indices of points outlining the face and additional points for symmetry calculation
    final faceOutlinePoints = [
      1, 17, ...List.generate(16, (index) => 17 + index), // Jawline
      78, ...List.generate(19, (index) => 78 + index), // Lips
      308, ...List.generate(12, (index) => 308 + index), // Lips
      10, ...List.generate(6, (index) => 10 + index), // Chin
      152, ...List.generate(8, (index) => 152 + index), // Upper lip
      234, ...List.generate(12, (index) => 234 + index), // Cheekbones
      454, ...List.generate(12, (index) => 454 + index), // Cheekbones
      127,
      ...List.generate(14, (index) => 127 + index), // Upper cheek and temple
      356,
      ...List.generate(14, (index) => 356 + index), // Upper cheek and temple
    ];

    final eyePoints = [
      33, ...List.generate(6, (index) => 33 + index), // Eye corners
      362, ...List.generate(6, (index) => 362 + index), // Eye corners
      159, ...List.generate(14, (index) => 159 + index), // Eyes
      386, ...List.generate(14, (index) => 386 + index), // Eyes
    ];

    final nosePoints = [
      199, ...List.generate(4, (index) => 199 + index), // Nose bridge
      4, ...List.generate(4, (index) => 4 + index), // Nose tip
    ];

    final mouthPoints = [
      78, ...List.generate(19, (index) => 78 + index), // Lips
      308, ...List.generate(12, (index) => 308 + index), // Lips
    ];


    double calculateAngleFromMidline(
        FaceMeshPoint midPoint, FaceMeshPoint a, FaceMeshPoint b) {
      final midX = midPoint.x;
      final midY = midPoint.y;
      final midZ = midPoint.z;

      final aVectorX = a.x - midX;
      final aVectorY = a.y - midY;
      final aVectorZ = a.z - midZ;
      final bVectorX = b.x - midX;
      final bVectorY = b.y - midY;
      final bVectorZ = b.z - midZ;

      final aDotB =
          aVectorX * bVectorX + aVectorY * bVectorY + aVectorZ * bVectorZ;
      final aMagnitude =
          sqrt(pow(aVectorX, 2) + pow(aVectorY, 2) + pow(aVectorZ, 2));
      final bMagnitude =
          sqrt(pow(bVectorX, 2) + pow(bVectorY, 2) + pow(bVectorZ, 2));

      // Ensure magnitudes are non-zero to prevent division by zero
      if (aMagnitude == 0 || bMagnitude == 0) {
        return double.nan;
      }

      final cosAngle = aDotB / (aMagnitude * bMagnitude);
      return acos(cosAngle) * 180 / pi;
    }

    double calculateSymmetryScore(List<int> pointIndices, double weightFactor) {
      double totalSymmetry = 0;
      int validPairs = 0;

      // Ensure there are enough points for midpoint calculation
      if (_faceMeshPoints == null || _faceMeshPoints!.length < 3) return 0;

      var midPoint =
          calculateMidPoint(_faceMeshPoints![1], _faceMeshPoints![2]);

      for (var i = 0; i < pointIndices.length ~/ 2; i++) {
        final leftIndex = pointIndices[i * 2];
        final rightIndex = pointIndices[i * 2 + 1];

        // Check if the indices are within bounds
        if (leftIndex < _faceMeshPoints!.length &&
            rightIndex < _faceMeshPoints!.length) {
          var leftPoint = _faceMeshPoints![leftIndex];
          var rightPoint = _faceMeshPoints![rightIndex];

          var angleFromMidline =
              calculateAngleFromMidline(midPoint, leftPoint, rightPoint);

          // Check for valid angle and avoid division by zero
          if (angleFromMidline.isFinite) {
            var symmetryScore =
                (180 - angleFromMidline) / 180 * 100 * weightFactor;
            totalSymmetry += symmetryScore;
            validPairs++;
          }
        } else {
        }
      }

      return validPairs > 0 ? totalSymmetry / validPairs : 0;
    }

    // Calculate symmetry scores
    _symmetryPercentage = calculateSymmetryScore(faceOutlinePoints, 1.0);
    _eyeSymmetry = calculateSymmetryScore(eyePoints, 1.0);
    _noseSymmetry = calculateSymmetryScore(nosePoints, 1.0);
    _mouthSymmetry = calculateSymmetryScore(mouthPoints, 1.0);


    _deductCredits(10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Symmetryresults(
            image: widget.imageFile,
            results:
                'Eye Symmetry: ${_eyeSymmetry?.toStringAsFixed(2) ?? "NaN"}%, Nose Symmetry: ${_noseSymmetry?.toStringAsFixed(2) ?? "NaN"}%, Mouth Symmetry: ${_mouthSymmetry?.toStringAsFixed(2) ?? "NaN"}%, Face Outline Symmetry: ${_symmetryPercentage?.toStringAsFixed(2) ?? "NaN"}%',
          ),
        ),
      );
    });
    setState(() {});
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
