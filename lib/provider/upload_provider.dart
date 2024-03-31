import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/upload_repsonse.dart';

class UploadProvider extends ChangeNotifier {
  final ApiService apiService;

  UploadProvider({required this.apiService});

  bool isUploading = false;
  String message = "";
  bool isSuccess = false;
  bool _isEnabled = false;
  LatLng? _currentCoordinate;
  bool _isLocationGranted = false;

  set isLocationGranted(bool newValue) {
    _isLocationGranted = newValue;
    notifyListeners();
  }

  bool get isLocationGranted => _isLocationGranted;

  set curentCorrdinate(LatLng? latLng) => _currentCoordinate = latLng;

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

      uploadResponse = switch (_currentCoordinate != null) {
        true => await apiService.addNewStory(bytes, fileName, description,
            _currentCoordinate!.latitude, _currentCoordinate!.longitude),
        false => await apiService.addNewStoryWithoutLocation(
            bytes, fileName, description)
      };
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

  Future<List<int>> compressImage(XFile xFile) async {
    var result = await FlutterImageCompress.compressWithFile(
      xFile.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 20,
    );

    return result?.toList() ?? [];
  }
}
