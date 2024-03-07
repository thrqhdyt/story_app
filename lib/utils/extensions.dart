import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/common.dart';

extension DateUtils on DateTime {
  String relativeTimeSpan(BuildContext context) {
    Duration diff = DateTime.now().difference(this);

    if (diff.inDays >= 1) {
      return '${diff.inDays} ${AppLocalizations.of(context)!.timeUploadDays}';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} ${AppLocalizations.of(context)!.timeUploadHours}';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} ${AppLocalizations.of(context)!.timeUploadMinutes}';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${AppLocalizations.of(context)!.timeUploadSeconds}';
    } else {
      return AppLocalizations.of(context)!.timeUploadJustNow;
    }
  }
}

extension GoRouterExtension on GoRouter {
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    final String location = matchList.uri.toString();
    return location;
  }
}
