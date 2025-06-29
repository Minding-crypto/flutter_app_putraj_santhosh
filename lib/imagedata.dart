import 'package:flutter/material.dart';

class ImageData extends ChangeNotifier {
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get images => _images;
  bool get isLoading => _isLoading;

  void setImages(List<Map<String, dynamic>> images) {
    _images = images;
    _isLoading = false;
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
