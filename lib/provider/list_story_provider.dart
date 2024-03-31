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

  int? _pageItems = 1;
  int sizeItems = 10;

  set pageItems(int? newValue) => _pageItems = newValue;
  // ignore: unnecessary_getters_setters
  int? get pageItems => _pageItems;

  Future<dynamic> fetchAllStories() async {
    try {
      if (_pageItems == 1) {
        _state = ResultState(status: Status.loading, message: null, data: null);
        notifyListeners();
      }
      final stories = await apiService.listStory(_pageItems!, sizeItems);
      if (stories.listStory.isEmpty) {
        _state = ResultState(
            status: Status.noData, message: 'Empty Data', data: null);
        notifyListeners();
        return _state;
      } else {
        _state =
            ResultState(status: Status.hasData, message: null, data: stories);
        if (stories.listStory.length < sizeItems) {
          _pageItems = null;
        } else {
          _pageItems = _pageItems! + 1;
        }
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
