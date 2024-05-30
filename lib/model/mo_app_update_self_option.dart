
class MoAppUpdateSelfOption {
  MoAppUpdateSelfOption({this.infoUrl, this.infoStr, this.currentBuildNumber});

  final String? infoUrl;
  final String? infoStr;
  final int? currentBuildNumber;

  copyOf({String? infoUrl, String? infoStr, int? currentBuildNumber}) {
    return MoAppUpdateSelfOption(
      infoStr: infoStr ?? this.infoStr,
      infoUrl: infoUrl ?? this.infoUrl,
      currentBuildNumber: currentBuildNumber ?? this.currentBuildNumber,
    );
  }
}