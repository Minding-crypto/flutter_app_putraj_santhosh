import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:instaclone/results/testresults.dart';

class Testscan extends StatefulWidget {
  final File imageFile; // Image file passed from ScanEyeQualityCards

  const Testscan({super.key, required this.imageFile});

  @override
  TestscanState createState() => TestscanState();
}

class TestscanState extends State<Testscan> {
  bool _isFacePresent = false;
  FaceDetector? faceDetector;
 

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
   
      // Process image after fetching credits
      _processImage(widget.imageFile);
   
  }



  void _initializeFaceDetector() {
    faceDetector?.close();
    faceDetector = FaceDetector(options: FaceDetectorOptions());
    
   
  }

  Future<void> _processImage(File imageFile) async {
  
// Load ui.Image
    setState(() {});

    // Now detect face with delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectFaceWithDelay(imageFile);
    });
  }


  Future<void> _detectFaceWithDelay(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await faceDetector!.processImage(inputImage);

    setState(() {
      _isFacePresent = faces.isNotEmpty;
    });

    if (!_isFacePresent) {
      // Show a snackbar or dialog and navigate back if no face is detected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Testresults(
            image: widget.imageFile,
            results: 'No Face Detected',
          ),
        ),
      );
      return;
    }

    // Delay for 1 second before moving forward
    Future.delayed(const Duration(microseconds: 1), () {
      // Proceed with your logic for face present scenario
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Testresults(
            image: widget.imageFile,
            results: 'Face Detected', // Assuming you only want to process the first detected face
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Returning an empty container since this page should be invisible
    return Container();
  }

  @override
  void dispose() {
    faceDetector?.close(); // Release resources when the widget is disposed
    super.dispose();
  }
}
