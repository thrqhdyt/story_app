import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class NewStoryProvider extends ChangeNotifier {
  String? imagePath;

  XFile? imageFile;

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }

  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }
}
