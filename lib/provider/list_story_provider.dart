import 'package:flutter/material.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/list_story_response.dart';
import 'package:story_app/utils/result_state.dart';

class ListStoryProvider extends ChangeNotifier {
  final ApiService apiService;

  ListStoryProvider({required this.apiService});

  ResultState<ListStoryResponse> _state =
      ResultState(status: Status.loading, message: null, data: null);

  ResultState<ListStoryResponse> get state => _state;

  Future<dynamic> fetchAllStories() async {
    try {
      _state = ResultState(status: Status.loading, message: null, data: null);
      notifyListeners();
      final stories = await apiService.listStory();
      if (stories.listStory.isEmpty) {
        _state = ResultState(
            status: Status.noData, message: 'Empty Data', data: null);
        notifyListeners();
        return _state;
      } else {
        _state =
            ResultState(status: Status.hasData, message: null, data: stories);
        notifyListeners();
        return _state;
      }
    } on Exception catch (e) {
      _state =
          ResultState(status: Status.error, message: e.toString(), data: null);
      notifyListeners();
      return _state;
    }
  }
}
