import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:instaclone/results/sideprofilenoseresults.dart';
import 'package:instaclone/roboflow/skin/skintype.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:tflite_v2/tflite_v2.dart';
import 'package:image/image.dart' as img;

class Scansnosehapetflitecards extends StatefulWidget {
  const Scansnosehapetflitecards({super.key});

  @override
  ScansnosehapetflitecardsState createState() => ScansnosehapetflitecardsState();
}

class ScansnosehapetflitecardsState extends State<Scansnosehapetflitecards> {
  final PageController _controller = PageController();
    final picker = ImagePicker();
  XFile? _image;
    File? file;
  var _recognitions;
  var v = "";
  bool isLoading = false;
  int _userCredits = 0;
  

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
      _fetchUserCredits();
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
    }
  }
}




  final List<String> _instructions = [
    'Swipe right to learn what type of images not to upload.',
    'Swipe right to learn what type of images to upload.',
    ''
  ];

  final List<Map<String, dynamic>> _firstPageInstructions = [
    {
      'image': null,
      'text': RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1, // Adjust the height of the line
                    width: 50, // Adjust the width of the line
                    color: Colors.white, // Adjust the color of the line
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Scan Your Nose',
                      style: GoogleFonts.bebasNeue(
                        textStyle: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1, // Adjust the height of the line
                    width: 50, // Adjust the width of the line
                    color: Colors.white, // Adjust the color of the line
                  ),
                ],
              ),
            ),
            const TextSpan(
              text: '\n\n',
            ), // Add spacing here (e.g., two line breaks)
            WidgetSpan(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Follow Image Upload Instructions',
                      style: GoogleFonts.josefinSans(
                        textStyle: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    }
  ];

  final List<Map<String, dynamic>> _secondPageInstructions = [
     {
      'image': 'assets/Screenshot 2024-06-09 160938.png',
      'text': const Row(
  children: [
    Text( '✔ ',
              style: TextStyle(color: Color.fromARGB(255, 39, 255, 104), fontSize: 18),),
    SizedBox(width: 5), // Adjust the spacing between the icon and the text
    Flexible(
      child: Text(
        "Zoom in on the Side Profile of The Nose",
        style: TextStyle(color: Colors.white, fontSize: 18),
        overflow: TextOverflow.visible,
      ),
    ),
  ],
)



    },
      {
      'image':
          'assets/3650026500ge9pO9TrwDOc49L65IdNwIEgF7MFZcx2ONoA08Nna5cNy4cG2DG8lYZG16gkVWwR_0_1_r.jpg',
     'text': const Row(
        children: [
          Text(
            '❌ ',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          SizedBox(
              width: 5), // Adjust the spacing between the icon and the text
          Flexible(
            child: Text(
              "No Full Front Profile",
              style: TextStyle(color: Colors.white, fontSize: 17),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      )
    },

    {
      'image': 'assets/profile.jpg',
       'text': const Row(
        children: [
          Text(
            '❌ ',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          SizedBox(
              width: 5), // Adjust the spacing between the icon and the text
          Flexible(
            child: Text(
              "No Full Side Profile",
              style: TextStyle(color: Colors.white, fontSize: 17),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      )
    },
  
    {
      'image': 'assets/eraseid_3983329833LQQJwmSn2h06XHLBticihVXn14mysHT9vAQ6OYNHmjRRxsvHaxp0MmzOesrdP9ok_y7fFICAC (1) (1).jpg',
      'text': const Row(
        children: [
          Text(
            '❌ ',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          SizedBox(
              width: 5), // Adjust the spacing between the icon and the text
          Flexible(
            child: Text(
              "No Group Photos",
              style: TextStyle(color: Colors.white, fontSize: 17),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      )
    },

    

   
  ];

  void goToScanPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Skintype()),
    );
  }

 


  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedImage != null) {
          // Resize the cropped image
          img.Image? imageTemp = img.decodeImage(await croppedImage.readAsBytes());
          double aspectRatio = imageTemp!.width / imageTemp.height;
          int targetWidth = 224;
          int targetHeight = (224 / aspectRatio).round();
          img.Image resizedImg = img.copyResize(imageTemp, width: targetWidth, height: targetHeight);
          File resizedImageFile = await File('${pickedFile.path}_resized.png').writeAsBytes(img.encodePng(resizedImg));

          setState(() {
            _image = XFile(resizedImageFile.path); // Use the resized image
            isLoading = true;
          });

          detectImage(resizedImageFile); // Send the resized image for processing
        }
      }
    } catch (e) {
    }
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_nose.tflite",
      labels: "assets/nose.txt",
    );
  }

 /* Future<void> detectImage(File image) async {
    try {
      int startTime = DateTime.now().millisecondsSinceEpoch;
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        threshold: 0.05,
        imageMean: 0.0,
        imageStd: 255.0,
      );

      setState(() {
        _recognitions = recognitions; // Define _recognitions earlier in your code
        isLoading = false;
      });

      print("Inference took ${DateTime.now().millisecondsSinceEpoch - startTime}ms");

      if (_recognitions != null && _recognitions.isNotEmpty) {
        v = _recognitions[0]["label"].toString();
        Navigator.push(
          context,
          MaterialPageRoute(
               builder: (context) => Sideprofilenoseresults(results: v, image: _image!),
          ),
        );
      } else {
        print("No recognitions found.");
      }
    } catch (e) {
      print('Error detecting image: $e');
      setState(() {
        isLoading = false;
      });
    }
  }*/




 Future<void> detectImage(File image) async {
  try {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 7,
      threshold: 0.05,
      imageMean: 0.0,
      imageStd: 255.0,
    );

    setState(() {
      _recognitions = recognitions;
      isLoading = false;
    });


    if (_recognitions != null && _recognitions.isNotEmpty) {
      v = _recognitions[0]["label"].toString();
      // Check if the user has enough credits
      if (_userCredits >= 10) {
        // Deduct 10 credits if the scan is successful
        if (v.isNotEmpty) {
          _deductCredits(10);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Sideprofilenoseresults(results: v, image: _image!),
          ),
        );
      } else {
        // Navigate to the buy credits page if the user doesn't have enough credits
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BuyCreditsPage()),
        );
      }
    } else {
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
  }
}

   
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions', style: TextStyle(color: Colors.white),),
         iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _instructions.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // First page with grid view of images and instructions
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_firstPageInstructions[0]['image'] != null)
                          SizedBox(
                            height: 190.0,
                            // Set a fixed height for the images
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.asset(
                                _firstPageInstructions[0]['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _firstPageInstructions[0]['text'],
                      ],
                    ),
                  );
                } else if (index == 1) {
                  // Second page with grid view of images and instructions
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GridView.builder(
                            itemCount: _secondPageInstructions.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15.0,
                              mainAxisSpacing: 25,
                              childAspectRatio: 1 / 1.5,
                            ),
                            itemBuilder: (context, gridIndex) {
                              final instruction =
                                  _secondPageInstructions[gridIndex];
                              return Column(
                                children: [
                                  if (instruction['image'] != null)
                                    SizedBox(
                                      height:
                                          190.0, // Set a fixed height for the images
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Image.asset(
                                          instruction['image'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 0),
                                  instruction['text'],
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Other instruction pages
                   return Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        _instructions[index],
        style: const TextStyle(fontSize: 24, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      if (index == _instructions.length - 1) ...[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              _pickImage(ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
              ),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              minimumSize: const Size(150, 150), // Adjust the button size as needed
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera, // Use the icon you prefer (e.g., Icons.photo_library)
                      color: Colors.black, // Adjust the icon color as needed
                    ),
                    SizedBox(width: 8), // Add some space between the icon and text
                    Text(
                      'Select Image From Camera',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17, // Adjust the text size as needed
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Add some space between the text and the credits info
                Text(
                  '(-10 credits)',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14, // Adjust the text size as needed
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              _pickImage(ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
              ),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              minimumSize: const Size(250, 150), // Adjust the button size as needed
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library, // Use the icon you prefer (e.g., Icons.photo_library)
                      color: Colors.black, // Adjust the icon color as needed
                    ),
                    SizedBox(width: 8), // Add some space between the icon and text
                    Text(
                      'Select Image From Gallery',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17, // Adjust the text size as needed
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Add some space between the text and the credits info
                Text(
                  '(-10 credits)',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14, // Adjust the text size as needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
);

                }
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: _instructions.length,
            effect: const WormEffect(
              activeDotColor: Colors.blue,
              dotColor: Colors.grey,
              dotHeight: 12,
              dotWidth: 12,
            ),
          ),
          const SizedBox(height: 16), // Spacing below the indicator
        ],
      ),
    );
  }
}
