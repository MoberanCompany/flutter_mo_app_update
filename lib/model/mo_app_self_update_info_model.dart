
import 'package:mo_app_update/util/json_util.dart';

class MoAppSelfUpdateInfoResponse {

  /// Keys are buildNumber as String
  final Map<String, Map<String, MoAppSelfUpdateInfoModel>> platform;

  MoAppSelfUpdateInfoResponse({required this.platform});

  Map<String, MoAppSelfUpdateInfoModel>? get(String key) {
    return platform[key];
  }

  static MoAppSelfUpdateInfoResponse fromJson(json) {
    var parsed = JsonUtil.tryParse(json);

    Map<String, Map<String, MoAppSelfUpdateInfoModel>> map = {};
    if(parsed['android'] != null) {
      map['android'] = parsePlatform(parsed['android']);
    }
    if(parsed['ios'] != null) {
      map['ios'] = parsePlatform(parsed['ios']);
    }

    return MoAppSelfUpdateInfoResponse(
      platform: map,
    );
  }

  static Map<String, MoAppSelfUpdateInfoModel> parsePlatform(dynamic info) {
    return Map<String, MoAppSelfUpdateInfoModel>
        .fromEntries((info as Map)
        .entries
        .map((e) => MapEntry(e.key.toString(), MoAppSelfUpdateInfoModel.fromJson(e.value)))
    );
  }
}

/// priority 0~3. 3: force update, 2: major/feature update, 3: minor/UI update
class MoAppSelfUpdateInfoModel {
  final String downloadUrl;
  final String? versionString;
  final int? priority;
  final Map<String, String>? changelog;

  MoAppSelfUpdateInfoModel({required this.downloadUrl, this.versionString, this.priority, this.changelog});

  static MoAppSelfUpdateInfoModel fromJson(json) {
    var parsed = JsonUtil.tryParse(json);
    return MoAppSelfUpdateInfoModel(
      downloadUrl: parsed['downloadUrl'],
      versionString: parsed['versionString'],
      priority: int.tryParse(parsed['priority'] ?? ''),
      changelog: parsed['changelog']?.cast<String, String>(),
    );
  }

  toJson() {
    return {
      'downloadUrl': downloadUrl,
      'versionString': versionString,
      'priority': priority,
      'changelog': changelog,
    };
  }

}
