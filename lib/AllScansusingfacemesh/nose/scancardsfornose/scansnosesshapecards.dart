import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaclone/AllScansusingfacemesh/nose/nosemesh/noseshapemesh.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';





 // Import FaceMeshScreen

class Scansnosesshapecards extends StatefulWidget {
  const Scansnosesshapecards({super.key});

  @override
  ScansnosesshapecardsState createState() => ScansnosesshapecardsState();
}

class ScansnosesshapecardsState extends State<Scansnosesshapecards> {
  final PageController _controller = PageController();
  final picker = ImagePicker();
  File? file;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
      'image':
          'assets/3650026500ge9pO9TrwDOc49L65IdNwIEgF7MFZcx2ONoA08Nna5cNy4cG2DG8lYZG16gkVWwR_0_1_r.jpg',
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
      'image': 'assets/Screenshot 2024-06-09 160130.png',
        'text': const Row(
  children: [
    Text( '❌ ',
              style: TextStyle(color: Color.fromARGB(255, 39, 255, 104), fontSize: 18),),
    SizedBox(width: 5), // Adjust the spacing between the icon and the text
    Flexible(
      child: Text(
        "Don't Zoom In On The Nose",
        style: TextStyle(color: Colors.white, fontSize: 18),
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
        setState(() {
// Use the cropped image without resizing
          isLoading = true;
        });

        // Navigate to FaceMeshScreen with the selected image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Noseshapemesh(imageFile: File(croppedImage.path)), // Assuming FaceMeshScreen takes an imageFile argument
          ),
        );
      }
    }
  } catch (e) {
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
                              mainAxisSpacing: 0,
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


/*

thin nose
I/flutter (23883): Nose Width: 63.728177291636314
I/flutter (23883): Width to Height Ratio: 6.116182937997513
 */

/*

wide nose
I/flutter (23883): Nose Width: 69.36455006767721
I/flutter (23883): Width to Height Ratio: 4.631492713412666

narrow Noses: 50.88 mm - 63.73 mm
Normal Nose Width Range: 64 mm to 68 mm
Wide Noses: 68.91 mm - 71.87 mm
 */


/*
downturned nose
Width to Height Ratio
 */


/*
upturned nose
Width to Height Ratio

Downturned Nose: Width to Height Ratio > 6.6
Upturned Nose: Width to Height Ratio < 4.45
Straight Nose: Width to Height Ratio between 4.45 and 6.6
 */