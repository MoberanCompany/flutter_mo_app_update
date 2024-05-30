

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mo_app_update_platform_interface.dart';

/// An implementation of [MoAppUpdatePlatform] that uses method channels.
class MethodChannelMoAppUpdate extends MoAppUpdatePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mo_app_update');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

}
