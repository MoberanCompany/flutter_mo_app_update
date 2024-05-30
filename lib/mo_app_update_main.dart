
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:mo_app_update/mo_app_update.dart';
import 'package:mo_app_update/util/android_util.dart';
import 'package:mo_app_update/util/json_util.dart';
import 'package:package_info_plus/package_info_plus.dart';


class MoAppUpdate {

  MoAppUpdate._({required MoAppUpdateMode mode, MoAppUpdateSelfOption? selfOption, required PackageInfo packageInfo}) : _selfOption = selfOption, _mode = mode, platform = _getPlatform(), _packageInfo = packageInfo;

  final String platform;
  final MoAppUpdateMode _mode;
  final MoAppUpdateSelfOption? _selfOption;
  final PackageInfo _packageInfo;

  MoAppUpdateInfo? _updateInfo;
  MoAppUpdateInfo? get updateInfo => _updateInfo;

  DateTime? _lastCheckedTime;
  DateTime? get lastCheckedTime => _lastCheckedTime;

  static Future<MoAppUpdate> initialize({required MoAppUpdateMode mode, MoAppUpdateSelfOption? selfOption}) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if(mode == MoAppUpdateMode.self) {
      if(selfOption == null){
        throw Exception("selfOption must not null");
      }
      else {
        if(selfOption.infoStr == null && selfOption.infoUrl == null) {
          throw Exception('infoUrl or infoStr must not null');
        }
        else {
          int buildNumber = selfOption.currentBuildNumber ?? int.parse(packageInfo.buildNumber);

          var instance = MoAppUpdate._(
            mode: mode,
            selfOption: selfOption.copyOf(
              currentBuildNumber: buildNumber,
            ),
            packageInfo: packageInfo,
          );

          var updateInfo = await instance.fetchUpdateInfo();
          instance._updateInfo = updateInfo;
          instance._lastCheckedTime = DateTime.now();
          return instance;
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

  String getBuildNumber() {
    return _selfOption?.currentBuildNumber?.toString() ?? _packageInfo.buildNumber;
  }

  String getVersionCode() {
    return _packageInfo.version;
  }

  bool hasUpdate() {
    return updateInfo != null;
  }

  Future<MoAppUpdateInfo?> fetchUpdateInfo() async {
    if(_mode == MoAppUpdateMode.self) {
      var selfUpdateInfo = await _getSelfUpdateInfo();

      var selfInfo = _extractLatestUpdate(selfUpdateInfo);
      var info = MoAppUpdateInfo(
        currentVersion: _packageInfo.version,
        currentBuildNumber: _packageInfo.buildNumber,
        currentVersionString: '${_packageInfo.version}(${_packageInfo.buildNumber})',
        newVersion: selfInfo?.versionString,
        newBuildNumber: selfInfo?.buildNumber?.toString(),
        newVersionString: selfInfo == null ? null : '${selfInfo.versionString}(${selfInfo.buildNumber})',
        mode: MoAppUpdateMode.self,
        url: selfInfo?.downloadUrl,
        updatePriority: selfInfo?.priority,
        changelog: selfInfo?.changelog,
        hasUpdate: selfInfo != null,
      );

      _updateInfo = info;
      _lastCheckedTime = DateTime.now();

      return info;
    }
    else if(_mode == MoAppUpdateMode.store) {
      throw UnimplementedError("getUpdateInfo store not implemented");
    }
    else {
      throw NotSupportedPlatformException();
    }
  }

  Future<MoAppUpdateInfo?> getUpdateInfo() async {
    return updateInfo ?? await fetchUpdateInfo();
  }

  clearUpdateInfo() {
    _updateInfo = null;
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
      buildNumber: latestBuildNumber,
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

  Future procedureUpdate(MoAppUpdateInfo model) async {
    if(!model.hasUpdate) {
      return;
    }
    if(model.url == null) {
      throw Exception('url must not null');
    }
    var url = model.url!;
    if(model.mode == MoAppUpdateMode.self) {
      if(platform == 'android') {
        String? apkPath;
        try{
          apkPath = await AndroidUtil.downloadApk(url, model.newVersionString);
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
        throw UnimplementedError('procedureUpdate ios not implemented');
      }
    }
    else {
      throw UnimplementedError('procedureUpdate store not implemented');
    }
  }
}
