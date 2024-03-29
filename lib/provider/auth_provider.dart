import 'package:flutter/material.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/preferences/preferences_helper.dart';
import 'package:story_app/utils/result_state.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final PreferencesHelper preferencesHelper;

  AuthProvider(this.apiService, this.preferencesHelper) {
    checkIsLogin();
  }

  ResultState _state = ResultState(status: Status.initial);
  bool? _isLogin;

  ResultState get state => _state;
  bool? get isLogin => _isLogin;

  bool isLoadingLogin = false;
  bool isLoadingRegister = false;

  Future<bool> checkIsLogin() async {
    final token = await preferencesHelper.getToken;
    _isLogin = token.isNotEmpty;
    notifyListeners();
    return token.isNotEmpty;
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoadingRegister = true;
      _state = ResultState(status: Status.loading, message: null, data: null);
      notifyListeners();

      await apiService.register(name, email, password);
      _state = ResultState(status: Status.registered);
      notifyListeners();
    } catch (e) {
      _state = ResultState(
          status: Status.error, message: 'Error --> $e', data: null);

      notifyListeners();
    } finally {
      isLoadingRegister = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoadingLogin = true;
      _state = ResultState(status: Status.loading);
      notifyListeners();

      final login = await apiService.login(email, password);
      _state = ResultState(status: Status.hasData);
      preferencesHelper.setName(login.loginResult.name);
      preferencesHelper.setToken(login.loginResult.token);

      _isLogin = true;
      notifyListeners();
    } catch (e) {
      _state = ResultState(
          status: Status.error, message: 'Error --> $e', data: null);
      notifyListeners();
    } finally {
      isLoadingLogin = false;
      notifyListeners();
    }
  }

  void logout() async {
    _state = ResultState(status: Status.loading);

    await preferencesHelper.setName('');
    await preferencesHelper.setToken('');
    _isLogin = false;

    _state = ResultState(status: Status.initial);
    notifyListeners();
  }
}
