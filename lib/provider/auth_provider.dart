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

  void checkIsLogin() async {
    await Future.delayed(const Duration(seconds: 3), () async {
      final token = await preferencesHelper.getToken;
      _isLogin = token.isNotEmpty;
      debugPrint("token is not empty: $_isLogin");

      notifyListeners();
    });
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoadingRegister = true;
      _state = ResultState(status: Status.loading, message: null, data: null);
      notifyListeners();

      await apiService.register(name, email, password);
      _state = ResultState(status: Status.registered);

      isLoadingRegister = false;
      print("Register Succesfully bang");
      notifyListeners();
    } catch (e) {
      _state = ResultState(
          status: Status.error, message: 'Error --> $e', data: null);

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

      isLoadingLogin = false;
      print("Logeennn Succesfully bangg");
      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
      _state = ResultState(
          status: Status.error, message: 'Error --> $e', data: null);
      print("login error bang!!!!");
      notifyListeners();
    }
  }

  void logout() async {
    _state = ResultState(status: Status.loading);

    await preferencesHelper.setName('');
    await preferencesHelper.setToken('');
    _isLogin = false;

    _state = ResultState(status: Status.initial);

    print("logout succesfully bang!!!!");
    notifyListeners();
  }
}
