import 'package:mo_app_update/mo_app_update.dart';

class MoAppUpdateInfo {
  final String currentVersion;
  final String currentBuildNumber;
  final String currentVersionString;

  final String? newVersion;
  final String? newBuildNumber;
  final String? newVersionString;

  final MoAppUpdateMode mode;
  final String? url;

  final bool hasUpdate;
  final int? updatePriority;
  final Map<String, String>? changelog;

  MoAppUpdateInfo({
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.currentVersionString,
    this.newVersion,
    this.newBuildNumber,
    this.newVersionString,
    required this.mode,
    required this.url,
    required this.hasUpdate,
    this.updatePriority,
    this.changelog,
  });

}