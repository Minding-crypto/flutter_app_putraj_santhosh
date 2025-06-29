// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instaclone/results/jawlineresults.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image/image.dart' as img;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class Skintype extends StatefulWidget {
  const Skintype({super.key});

  @override
  State<Skintype> createState() => _SkintypeState();
}

class _SkintypeState extends State<Skintype> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/skintypeclassification.tflite",
      labels: "assets/skintypelabels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File originalImage = File(image.path);
        img.Image? imageTemp =
            img.decodeImage(await originalImage.readAsBytes());
        img.Image resizedImg =
            img.copyResize(imageTemp!, width: 224, height: 224);

        File resizedImageFile = await File('${originalImage.path}_resized.png')
            .writeAsBytes(img.encodePng(resizedImg));

        setState(() {
          _image = XFile(resizedImageFile.path);
          file = resizedImageFile;
          isLoading = true;
        });

        detectimage(resizedImageFile);
      }
    } catch (e) {
    }
  }

  Future detectimage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.05,
      imageMean: 0.0,
      imageStd: 255.0,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
      isLoading = false;
    });

    if (_recognitions != null && _recognitions.isNotEmpty) {
      var firstRecognition = _recognitions.first;

      String label = firstRecognition['label'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JawlineResults(results: label, image: _image!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFlite'),
        titleTextStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 30),
        backgroundColor: Color.fromARGB(255, 0, 159, 11),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),

      ),
      body: Container(
        decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 159, 11),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             

              //bebasneue
              //oswald
          Padding(
  padding: const EdgeInsets.only(right: 55.0),
  child: RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'Unlock Your Skin’s Secrets, Scan ',
          style: GoogleFonts.bebasNeue(
            textStyle: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
              letterSpacing: 0.00000000000000000001,
            ),
          ),
        ),
        TextSpan(
          text: 'now!',
          style: GoogleFonts.bebasNeue(
            textStyle: TextStyle(
              fontSize: 100,
              
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 204, 255, 0),
              letterSpacing: 0.00000000000000000001,
               decoration: TextDecoration.underline, 
            ),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = _pickImage,
        ),
      ],
    ),
  ),
),

              
              SizedBox(height: 20),
              if (isLoading)
                LoadingAnimationWidget.discreteCircle(
                  color: const Color.fromARGB(255, 255, 7, 7),
                  size: 30,
                )
              else
                Text(v),
            ],
          ),
        ),
      ),
    );
  }
}
