import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/color_schemes.g.dart';
import 'package:story_app/common/styles.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/preferences/preferences_helper.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/provider/detail_story_provider.dart';
import 'package:story_app/provider/new_story_provider.dart';
import 'package:story_app/provider/list_story_provider.dart';
import 'package:story_app/provider/upload_provider.dart';
import 'package:story_app/screen/add_story_screen.dart';
import 'package:story_app/screen/detail_story_screen.dart';
import 'package:story_app/screen/login_screen.dart';
import 'package:story_app/screen/register_screen.dart';
import 'package:story_app/screen/setting_screen.dart';
import 'package:story_app/screen/splash_screen.dart';
import 'package:story_app/screen/stories_list_screen.dart';
import 'package:story_app/widgets/adapative_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider authProvider;
  late final PreferencesHelper preferencesHelper;
  late final ApiService apiService;

  @override
  void initState() {
    super.initState();
    preferencesHelper =
        PreferencesHelper(sharedPreferences: SharedPreferences.getInstance());
    apiService = ApiService(preferencesHelper: preferencesHelper);

    authProvider = AuthProvider(apiService, preferencesHelper);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => authProvider,
        ),
        ChangeNotifierProvider<ListStoryProvider>(
          create: (_) => ListStoryProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<DetailStoryProvider>(
          create: (_) => DetailStoryProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<NewStoryProvider>(
          create: (_) => NewStoryProvider(),
        ),
        ChangeNotifierProvider<UploadProvider>(
          create: (_) => UploadProvider(apiService: apiService),
        )
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Story App',
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
          textTheme: myTextTheme,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
          textTheme: myTextTheme,
        ),
        routerConfig: GoRouter(
          initialLocation: '/splash',
          routes: [
            ShellRoute(
                builder: (_, __, child) => AdaptiveNavigation(child: child),
                routes: [
                  GoRoute(
                    path: '/stories',
                    builder: (_, __) => const StoriesListScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail/:storyId',
                        builder: (context, state) => DetailStoryScreen(
                          storyId: state.pathParameters['storyId'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/add_story',
                    builder: (_, __) => const AddStoryScreen(),
                  ),
                  GoRoute(
                    path: '/setting',
                    builder: (_, __) => const SettingScreen(),
                  ),
                ]),
            GoRoute(
              path: '/splash',
              builder: (_, __) => const SplashScreen(),
            ),
            GoRoute(
              path: '/signin',
              builder: (_, __) => const LoginScreen(),
            ),
            GoRoute(
              path: '/signup',
              builder: (_, __) => const RegisterScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
