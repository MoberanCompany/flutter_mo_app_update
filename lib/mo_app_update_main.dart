
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:mo_app_update/util/json_util.dart';
import 'package:mo_app_update/model/mo_app_self_update_info_model.dart';
import 'package:mo_app_update/model/mo_app_update_mode.dart';
import 'package:mo_app_update/model/mo_app_update_self_option.dart';
import 'package:mo_app_update/util/android_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'exception/not_supported_platform_exception.dart';
import 'mo_app_update_platform_interface.dart';

class MoAppUpdate {

  MoAppUpdate._({required MoAppUpdateMode mode, MoAppUpdateSelfOption? selfOption}) : _selfOption = selfOption, _mode = mode, platform = _getPlatform();

  final String platform;
  final MoAppUpdateMode _mode;
  final MoAppUpdateSelfOption? _selfOption;

  static Future<MoAppUpdate> initialize({required MoAppUpdateMode mode, MoAppUpdateSelfOption? selfOption}) async {
    if(mode == MoAppUpdateMode.self) {
      if(selfOption == null){
        throw Exception("selfOption must not null");
      }
      else {
        if(selfOption.infoStr == null && selfOption.infoUrl == null) {
          throw Exception('infoUrl or infoStr must not null');
        }
        else {
          int? buildNumber = selfOption.currentBuildNumber;
          if(buildNumber == null) {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            buildNumber = int.parse(packageInfo.buildNumber);
          }

          return MoAppUpdate._(
            mode: mode,
            selfOption: selfOption.copyOf(
              currentBuildNumber: buildNumber,
            ),
          );
        }
      }
    }
    else if(mode == MoAppUpdateMode.store) {
      throw UnimplementedError("initialize store not implemented");
    }
    else {
      throw NotSupportedPlatformException();
    }
  }

  Future<MoAppSelfUpdateInfoModel?> getUpdateInfo() async {
    if(_mode == MoAppUpdateMode.self) {
      var selfUpdateInfo = await _getSelfUpdateInfo();

      return _extractLatestUpdate(selfUpdateInfo);
    }
    else if(_mode == MoAppUpdateMode.store) {
      throw UnimplementedError("getUpdateInfo store not implemented");
    }
    else {
      throw NotSupportedPlatformException();
    }
  }

  MoAppSelfUpdateInfoModel? _extractLatestUpdate(MoAppSelfUpdateInfoResponse info) {
    int currentBuildNumber = _selfOption!.currentBuildNumber!;
    var platformInfo = info.get(platform);
    var buildNumberList = platformInfo!.keys.map((e) => int.parse(e)).toList();
    buildNumberList.sort();
    var latestBuildNumber = buildNumberList.last;
    if(latestBuildNumber <= currentBuildNumber) {
      return null;
    }

    var latestInfo = platformInfo['$latestBuildNumber']!;
    var updateList = Map<String, MoAppSelfUpdateInfoModel>
        .fromEntries(
        platformInfo
            .entries
            .where((e) => int.parse(e.key) > currentBuildNumber
            && int.parse(e.key) <= latestBuildNumber
        )
    );

    var maxPriority = updateList.values.map((e) => e.priority ?? 0).reduce(max);

    return MoAppSelfUpdateInfoModel(
      downloadUrl: latestInfo.downloadUrl,
      priority: maxPriority,
      versionString: latestInfo.versionString,
      changelog: latestInfo.changelog,
    );
  }

  Future<MoAppSelfUpdateInfoResponse> _getSelfUpdateInfo() async {
    if(_selfOption == null) {
      throw Exception("selfOption must not null");
    }
    var selfOption = _selfOption!;
    if(selfOption.currentBuildNumber == null) {
      throw Exception("selfOption.currentBuildNumber must not null");
    }
    Map json;
    if(selfOption.infoStr != null){
      json = JsonUtil.tryParseObject(selfOption.infoStr!);
    }
    else {
      if(selfOption.infoUrl == null) {
        throw Exception("selfOption.infoUrl must not null");
      }
      Uri url = Uri.parse(selfOption.infoUrl!);
      var res = await http.get(url);
      json = JsonUtil.tryParseObject(utf8.decode(res.bodyBytes));
    }

    var model = MoAppSelfUpdateInfoResponse.fromJson(json);
    return model;
  }

  static String _getPlatform() {
    if(Platform.isIOS) {
      return 'ios';
    }
    else if(Platform.isAndroid) {
      return 'android';
    }
    else {
      throw NotSupportedPlatformException();
    }
  }

  Future<String?> getPlatformVersion() {
    return MoAppUpdatePlatform.instance.getPlatformVersion();
  }

  Future procedureSelfUpdate(MoAppSelfUpdateInfoModel model) async {
    if(platform == 'android') {
      String? apkPath;
      try{
        apkPath = await AndroidUtil.downloadApk(model.downloadUrl, model.versionString);
        var res = await AndroidUtil.installApk(apkPath);
        return res;
      }
      finally {
        if(apkPath != null) {
          var file = File(apkPath);
          if(await file.exists()) {
            await file.delete();
          }
        }
      }
    }
    else {
      throw UnimplementedError('procedureSelfUpdate ios not implemented');
    }
  }
}
