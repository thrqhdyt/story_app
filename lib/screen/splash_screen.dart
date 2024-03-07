import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:story_app/provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          if (mounted) {
            final isLogin = await context.read<AuthProvider>().checkIsLogin();
            if (isLogin == true) {
              context.pushReplacement('/stories');
            } else if (isLogin == false) {
              context.pushReplacement('/signin');
            }
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/splash_animation.json'),
            ],
          ),
        ),
      );
    });
  }
}
