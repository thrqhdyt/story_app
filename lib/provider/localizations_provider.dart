import 'package:flutter/material.dart';
import 'package:story_app/preferences/preferences_helper.dart';

class LocalizationsProvider extends ChangeNotifier {
  final PreferencesHelper preferencesHelper;

  LocalizationsProvider({required this.preferencesHelper}) {
    Future.microtask(() => getLocale());
  }

  Locale _locale = const Locale("en");
  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    await preferencesHelper.setLanguange(locale.languageCode);
    notifyListeners();
  }

  void getLocale() async {
    _locale = Locale(await preferencesHelper.getLanguange);
    notifyListeners();
  }
}
