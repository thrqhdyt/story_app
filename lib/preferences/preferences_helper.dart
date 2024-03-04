import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  final Future<SharedPreferences> sharedPreferences;

  PreferencesHelper({required this.sharedPreferences});

  static const authName = "AUTH_NAME";
  static const authToken = "AUTH_TOKEN";

  Future<bool> get isLogin async {
    final prefs = await sharedPreferences;
    return prefs.getBool(authToken) ?? false;
  }

  Future<String> get getName async {
    final prefs = await sharedPreferences;
    return prefs.getString(authName) ?? "";
  }

  Future<void> setName(String value) async {
    final prefs = await sharedPreferences;
    prefs.setString(authName, value);
  }

  Future<String> get getToken async {
    final prefs = await sharedPreferences;
    final token = prefs.getString(authToken) ?? "";
    return token;
  }

  Future<void> setToken(String value) async {
    final prefs = await sharedPreferences;
    prefs.setString(authToken, value);
  }
}
