import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/provider/auth_provider.dart';

class StoriesListScreen extends StatelessWidget {
  final Function() onLogout;

  const StoriesListScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StoryApp"),
        actions: [
          IconButton(
            onPressed: () {
              final authRead = context.read<AuthProvider>();
              authRead.logout();
              onLogout();
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Text("This Is Home Screen"),
      ),
    );
  }
}
