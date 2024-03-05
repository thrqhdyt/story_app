import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

List<BottomNavigationBarItem> listNavigationItems(BuildContext context) => [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: FloatingActionButton.small(
            onPressed: () => context.pushReplacement('/add_story'),
            child: const Icon(Icons.add)),
        label: "Add Story",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Setting",
      )
    ];
