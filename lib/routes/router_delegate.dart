import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/screen/login_screen.dart';
import 'package:story_app/screen/register_screen.dart';
import 'package:story_app/screen/splash_screen.dart';
import 'package:story_app/screen/stories_list_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;

  final AuthProvider authProvider;

  MyRouterDelegate(
    this.authProvider,
  ) : _navigatorKey = GlobalKey<NavigatorState>();
  bool? isLoggedIn;
  bool isRegister = false;

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  List<Page> historyStack = const [
    MaterialPage(
      key: ValueKey("SplashPage"),
      child: SplashScreen(),
    ),
  ];
  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginScreen(
            onLogin: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterScreen(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];
  List<Page> get _loggedInStack => [
        MaterialPage(
          key: ValueKey("StoriesListPage"),
          child: StoriesListScreen(
            onLogout: () {
              isLoggedIn = false;
              notifyListeners();
            },
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, provider, widget) {
      historyStack = switch (provider.isLogin) {
        null => historyStack,
        true => _loggedInStack,
        false => _loggedOutStack
      };
      return Navigator(
        key: navigatorKey,
        pages: historyStack,
        onPopPage: (route, result) {
          final didPop = route.didPop(result);
          if (!didPop) {
            return false;
          }

          isRegister = false;
          notifyListeners();

          return true;
        },
      );
    });
  }

  @override
  Future<void> setNewRoutePath(configuration) {
    throw UnimplementedError();
  }
}
