import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/styles.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/preferences/preferences_helper.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/routes/router_delegate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate myRouterDelegate;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService();
    final preferencesHelper =
        PreferencesHelper(sharedPreferences: SharedPreferences.getInstance());

    authProvider = AuthProvider(apiService, preferencesHelper);

    myRouterDelegate = MyRouterDelegate(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => authProvider,
      child: MaterialApp(
        title: 'Story App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
          textTheme: myTextTheme,
        ),
        home: Router(
          routerDelegate: myRouterDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
