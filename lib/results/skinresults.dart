import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final Uint8List imageBytes;
  final String inferenceResult;

  const ResultsPage({super.key, required this.imageBytes, required this.inferenceResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inference Results'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Inference Results',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Image.memory(imageBytes),
            const SizedBox(height: 16.0),
            Text(
              inferenceResult,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
