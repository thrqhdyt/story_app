import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/upload_repsonse.dart';

class UploadProvider extends ChangeNotifier {
  final ApiService apiService;

  UploadProvider({required this.apiService});

  bool isUploading = false;
  String message = "";
  bool isSuccess = false;
  bool _isEnabled = false;

  set isEnabled(bool newValue) {
    _isEnabled = newValue;
    notifyListeners();
  }

  bool get isEnabled => _isEnabled;

  UploadResponse? uploadResponse;

  Future<void> upload(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    try {
      message = "";
      uploadResponse = null;
      isUploading = true;
      notifyListeners();

      uploadResponse =
          await apiService.addNewStory(bytes, fileName, description);
      message = uploadResponse?.message ?? "success";
      isUploading = false;
      isSuccess = true;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];

    do {
      compressQuality -= 10;

      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );

      length = newByte.length;
    } while (length > 1000000);

    return newByte;
  }
}
