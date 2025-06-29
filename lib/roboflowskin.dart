
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;


class InferenceScreen extends StatefulWidget {
  const InferenceScreen({super.key});

  @override
  InferenceScreenState createState() => InferenceScreenState();
}

class InferenceScreenState extends State<InferenceScreen> {
  Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inference App')),
      body: Center(
        child: _imageBytes == null
            ? const Text('Press the button to start inference')
            : Image.memory(_imageBytes!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => inferOnLocalImage(),
        child: const Icon(Icons.image),
      ),
    );
  }

  void inferOnLocalImage() async {
    String assetPath = 'assets/Screenshot 2024-06-02 210646.png';
    String apiUrl = 'https://detect.roboflow.com/acne-new/3';
    String apiKey = 'NFgy0XiYG3DrmL7gUS5i';
    double confidenceThreshold = 0; // Fixed confidence threshold

    try {
      ByteData imageData = await rootBundle.load(assetPath);
      List<int> imageBytes = imageData.buffer.asUint8List();

      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl?api_key=$apiKey&format=image&confidence=$confidenceThreshold'));
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.png'));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
        });
      } else {
      }
    } catch (e) {
    }
  }
}
