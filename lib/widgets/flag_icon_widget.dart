import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/common.dart';
import 'package:story_app/provider/localizations_provider.dart';
import 'package:story_app/utils/localization.dart';

class FlagIconWidget extends StatelessWidget {
  const FlagIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        icon: const Icon(Icons.language_rounded),
        items: AppLocalizations.supportedLocales.map((Locale locale) {
          final flag = Localization.getFlag(locale.languageCode);
          return DropdownMenuItem(
            value: locale,
            child: Center(
              child: Text(
                flag,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            onTap: () {
              final provider =
                  Provider.of<LocalizationsProvider>(context, listen: false);
              provider.setLocale(locale);
            },
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }
}
