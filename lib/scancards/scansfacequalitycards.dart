import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:instaclone/results/skinqualityresults.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ScansfacequalityCards extends StatefulWidget {
  const ScansfacequalityCards({Key? key}) : super(key: key);

  @override
  ScansfacequalityCardsState createState() => ScansfacequalityCardsState();
}

class ScansfacequalityCardsState extends State<ScansfacequalityCards> {
  final PageController _controller = PageController();
  final picker = ImagePicker();
  File? file;
  var v = "";
  bool isLoading = false; // Add this variable to track loading state
  Uint8List? _imageBytes;
  String _inferenceResult = '';
  int _userCredits = 0;

  @override
void initState() {
  super.initState();
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
    '',
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
                    height: 1,
                    width: 50,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Scan Your Skin',
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
                    height: 1,
                    width: 50,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const TextSpan(
              text: '\n\n',
            ),
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
      'image':
          'assets/3662326623zvk4fcWMxrO6ZUvjEOsRoHIavQnjayOi1vwIobTVAlcquCH1jE0DoFPqs0PkPDVO_0_0_r.jpg',
      'text': const Row(
        children: [
          Text(
            '✔',
            style: TextStyle(color: Color.fromARGB(255, 36, 255, 65), fontSize: 18),
          ),
          SizedBox(
              width: 5), // Adjust the spacing between the icon and the text
          Flexible(
            child: Text(
              'Full Front Profile',
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
              "No Side Profile",
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

    {
      'image': 'assets/3662326623sD1M9nyuUU1ZYMqKQdfc9d6SgEZA0j7LBLgdyaHvPjQcuBIqZD7NF10Zk9hh3DSv_0_0_r.jpg',
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
              "Remove Any Eyewear",
              style: TextStyle(color: Colors.white, fontSize: 17),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      )
    },
  ];

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
        img.Image? imageTemp = img.decodeImage(await croppedImage.readAsBytes());
        double aspectRatio = imageTemp!.width / imageTemp.height;
        int targetWidth = 224;
        int targetHeight = (224 / aspectRatio).round();
        img.Image resizedImg = img.copyResize(imageTemp, width: targetWidth, height: targetHeight);
        File resizedImageFile = await File('${pickedFile.path}_resized.png').writeAsBytes(img.encodePng(resizedImg));

        Uint8List imageBytes = await resizedImageFile.readAsBytes(); // Update _imageBytes here

        setState(() {
          _imageBytes = imageBytes;
          isLoading = true;
        });

        detectImage(resizedImageFile); // Send the resized image for processing
      }
    }
  } catch (e) {
  }
}

  void detectImage(File image) async {
    String apiUrl = 'https://detect.roboflow.com/acne-new/3';
    String apiKey = 'NFgy0XiYG3DrmL7gUS5i';
    double confidenceThreshold = 0.1;

    try {
      List<int> imageBytes = await image.readAsBytes();

      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiUrl?api_key=$apiKey&format=json&confidence=$confidenceThreshold'));
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.png'));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        var predictions = result['predictions'];

        Map<String, int> predictionCounts = {};

        for (var prediction in predictions) {
          String predictedClass = prediction['class'];
          if (predictionCounts.containsKey(predictedClass)) {
            predictionCounts[predictedClass] = predictionCounts[predictedClass]! + 1;
          } else {
            predictionCounts[predictedClass] = 1;
          }
        }

        String formattedResult = predictionCounts.entries.map((entry) => '${entry.key}x${entry.value}').join(', ');


        setState(() {
          _inferenceResult = formattedResult;
          isLoading = false;

          // Check if the user has enough credits before deducting
          if (_userCredits >= 10) {
            _deductCredits(10); // Deduct 10 credits

            // Navigate to the ResultsPage to display the JSON result
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Skinqualityresults(
                  image: _imageBytes!,
                  results: _inferenceResult,
                ),
              ),
            );
          } else {
            // Navigate to the BuyCreditsPage if the user doesn't have enough credits
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuyCreditsPage()),
            );
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
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
        title: const Text('Instructions', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
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
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15.0,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 1 / 1.5,
                                ),
                                itemBuilder: (context, gridIndex) {
                                  final instruction = _secondPageInstructions[gridIndex];
                                  return Column(
                                    children: [
                                      if (instruction['image'] != null)
                                        SizedBox(
                                          height: 190.0, // Set a fixed height for the images
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
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

          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                 LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 50,
            ),
                    const SizedBox(height: 10),
                    const Text(
                      'Analyzing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
