import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:instaclone/results/eyebrowresults.dart';
import 'package:instaclone/scancards/creditspage.dart';

class Eyebrowmesh extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Eyebrowmesh({super.key, required this.imageFile});

  @override
  EyebrowmeshState createState() => EyebrowmeshState();
}

class EyebrowmeshState extends State<Eyebrowmesh> {
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
      _analyzeEyebrowShape();
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

  void _analyzeEyebrowShape() {
  // Indices for the eyebrows based on the face mesh model
  final leftEyebrowIndices = [70, 63, 105, 66, 107];
  final rightEyebrowIndices = [336, 296, 334, 293, 300];

  for (var index in leftEyebrowIndices) {
    if (index < _faceMeshPoints!.length) {
    }
  }

  for (var index in rightEyebrowIndices) {
    if (index < _faceMeshPoints!.length) {
    }
  }

  // Calculate curvature and angles to analyze eyebrow shape
  if (leftEyebrowIndices.every((index) => index < _faceMeshPoints!.length) &&
      rightEyebrowIndices.every((index) => index < _faceMeshPoints!.length)) {
    var leftEyebrowStart = _faceMeshPoints![leftEyebrowIndices[0]];
    var leftEyebrowEnd = _faceMeshPoints![leftEyebrowIndices[4]];
    var leftEyebrowArch = _faceMeshPoints![leftEyebrowIndices[2]];

    var rightEyebrowStart = _faceMeshPoints![rightEyebrowIndices[0]];
    var rightEyebrowEnd = _faceMeshPoints![rightEyebrowIndices[4]];
    var rightEyebrowArch = _faceMeshPoints![rightEyebrowIndices[2]];

    double calculateAngle(FaceMeshPoint a, FaceMeshPoint b, FaceMeshPoint c) {
      var ab = calculateDistance(a, b);
      var bc = calculateDistance(b, c);
      var ac = calculateDistance(a, c);
      return acos((ab * ab + bc * bc - ac * ac) / (2 * ab * bc)) * 180 / pi;
    }

    var leftEyebrowAngle =
        calculateAngle(leftEyebrowStart, leftEyebrowArch, leftEyebrowEnd);
    var rightEyebrowAngle =
        calculateAngle(rightEyebrowStart, rightEyebrowArch, rightEyebrowEnd);

    // Curvature Analysis
    double calculateCurvature(List<FaceMeshPoint> points) {
      double sumCurvature = 0.0;
      for (int i = 1; i < points.length - 1; i++) {
        var a = points[i - 1];
        var b = points[i];
        var c = points[i + 1];
        var ab = calculateDistance(a, b);
        var bc = calculateDistance(b, c);
        var ac = calculateDistance(a, c);
        double curvature =
            acos((ab * ab + bc * bc - ac * ac) / (2 * ab * bc)) * 180 / pi;
        sumCurvature += curvature;
      }
      return sumCurvature / (points.length - 2);
    }

    double leftEyebrowCurvature = calculateCurvature(
        leftEyebrowIndices.map((i) => _faceMeshPoints![i]).toList());
    double rightEyebrowCurvature = calculateCurvature(
        rightEyebrowIndices.map((i) => _faceMeshPoints![i]).toList());

    // Thickness Analysis
    double calculateThickness(
        FaceMeshPoint start, FaceMeshPoint end, FaceMeshPoint arch) {
      return (calculateDistance(start, arch) + calculateDistance(arch, end)) /
          2;
    }

    double leftEyebrowThickness =
        calculateThickness(leftEyebrowStart, leftEyebrowEnd, leftEyebrowArch);
    double rightEyebrowThickness = calculateThickness(
        rightEyebrowStart, rightEyebrowEnd, rightEyebrowArch);

    // Enhanced Shape Analysis
    String analyzeEyebrowShape(
        double angle, double curvature, double thickness) {
      if (angle > 150) {
        return "Straight";
      } else if (angle < 120) {
        return "Hard Angled";
      } else if (angle >= 120 && angle <= 150 && curvature > 170) {
        return "Soft Angled";
      } else if (curvature < 160) {
        return "Rounded";
      } else if (curvature >= 160 && curvature <= 170) {
        return "Curved";
      } else if (thickness > 0.5) {
        // Example threshold, needs tuning
        return "Tapered";
      } else {
        return "Arched";
      }
    }

    // Indices for the jawline based on the MediaPipe FaceMesh model
    final jawlineIndices = [
      1,
      152,
      148,
      176,
      149,
      150,
      177,
      148,
      109,
      116,
      117,
      118,
      119
    ];

    // Jawline analysis
    if (jawlineIndices.every((index) => index < _faceMeshPoints!.length)) {
      final jawlinePoints =
          jawlineIndices.map((i) => _faceMeshPoints![i]).toList();

      // Calculate the angle between the jawline and the chin
      final jawlineAngle = calculateAngle(
        jawlinePoints[0],
        jawlinePoints[jawlinePoints.length ~/ 2],
        jawlinePoints.last,
      );

      // Calculate the length of the jawline
      for (int i = 0; i < jawlinePoints.length - 1; i++) {
      }

      // Calculate the curvature or straightness of the jawline
      for (int i = 1; i < jawlinePoints.length - 1; i++) {
        final a = jawlinePoints[i - 1];
        final b = jawlinePoints[i];
        final c = jawlinePoints[i + 1];
        calculateAngle(a, b, c);
      }

      // Debugging prints

      // Determine if the jawline is strong, average, or weak
      if (jawlineAngle >= 36.5 && jawlineAngle < 38.5) {
      } else if (jawlineAngle >= 38.5 && jawlineAngle <= 45) {
      } else {
      }

    }

    String leftEyebrowShape = analyzeEyebrowShape(
        leftEyebrowAngle, leftEyebrowCurvature, leftEyebrowThickness);
    String rightEyebrowShape = analyzeEyebrowShape(
        rightEyebrowAngle, rightEyebrowCurvature, rightEyebrowThickness);

    _deductCredits(10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Eyebrowresults(
            image: widget.imageFile,
            results:
                'Left Eyebrow Shape: $leftEyebrowShape, Right Eyebrow Shape: $rightEyebrowShape',
          ),
        ),
      );
    });
  }
}

double calculateDistance(FaceMeshPoint a, FaceMeshPoint b) {
  return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
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

/*
STRONG JAWLINE DATA
I/flutter (11523): Jawline Angle: 39.724870115125505
I/flutter (11523): Jawline Length: 699.5233868069781
I/flutter (11523): Jawline Curvature: 110.8055711699682
I/flutter (11523): Jawline Shape: Weak Jawline 

I/flutter (11523): Jawline Angle: 40.016467328618376
I/flutter (11523): Jawline Length: 515.460732779758
I/flutter (11523): Jawline Curvature: 109.83869986106733
I/flutter (11523): Jawline Shape: Weak Jawline


I/flutter (11523): Jawline Angle: 39.4759264973645
I/flutter (11523): Jawline Length: 505.84238005284675
I/flutter (11523): Jawline Curvature: 110.71462924786375
I/flutter (11523): Jawline Shape: Weak Jawline

I/flutter (11523): Jawline Angle: 39.084181021698434
I/flutter (11523): Jawline Length: 640.2680626630561
I/flutter (11523): Jawline Curvature: 110.8675318070811
I/flutter (11523): Jawline Shape: Weak Jawline

*/


/*

WEAK JAWLINE DATA
I/flutter (11523): Jawline Angle: 35.435817262030355
I/flutter (11523): Jawline Length: 982.2507724533194
I/flutter (11523): Jawline Curvature: 110.9411461752477
I/flutter (11523): Jawline Shape: Weak Jawline 

I/flutter (11523): Jawline Angle: 27.81625741398148
I/flutter (11523): Jawline Length: 448.67149123733185
I/flutter (11523): Jawline Curvature: 111.32328862154658
I/flutter (11523): Jawline Shape: Weak Jawline

I/flutter (11523): Jawline Angle: 28.243093908792414
I/flutter (11523): Jawline Length: 769.2669414257663
I/flutter (11523): Jawline Curvature: 108.0409342911088
I/flutter (11523): Jawline Shape: Weak Jawline


I/flutter (11523): Jawline Angle: 28.732181628680394
I/flutter (11523): Jawline Length: 449.69787954087997
I/flutter (11523): Jawline Curvature: 109.58336747114721
I/flutter (11523): Jawline Shape: Weak Jawline*/