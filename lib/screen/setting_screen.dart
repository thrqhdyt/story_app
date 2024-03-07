import 'package:flutter/material.dart';
import 'package:story_app/common.dart';
import 'package:story_app/widgets/flag_icon_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingBtnNav,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.languange,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: FlagIconWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
