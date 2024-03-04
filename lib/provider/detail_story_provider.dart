import 'package:flutter/material.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/detail_story_response.dart';
import 'package:story_app/utils/result_state.dart';

class DetailStoryProvider extends ChangeNotifier {
  final ApiService apiService;

  DetailStoryProvider({required this.apiService});

  ResultState<DetailStoryResponse> _state =
      ResultState(status: Status.loading, message: null, data: null);

  ResultState<DetailStoryResponse> get state => _state;

  Future<dynamic> fetchDetailStory(String id) async {
    try {
      _state = ResultState(status: Status.loading, message: null, data: null);
      notifyListeners();
      final detailStory = await apiService.detailStory(id);
      _state =
          ResultState(status: Status.hasData, message: null, data: detailStory);
      notifyListeners();
      return _state;
    } catch (e) {
      _state = ResultState(
          status: Status.error, message: 'Error --> $e', data: null);
      notifyListeners();
      return _state;
    }
  }
}
