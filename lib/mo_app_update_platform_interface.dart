import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mo_app_update_method_channel.dart';

abstract class MoAppUpdatePlatform extends PlatformInterface {
  /// Constructs a MoAppUpdatePlatform.
  MoAppUpdatePlatform() : super(token: _token);

  static final Object _token = Object();

  static MoAppUpdatePlatform _instance = MethodChannelMoAppUpdate();

  /// The default instance of [MoAppUpdatePlatform] to use.
  ///
  /// Defaults to [MethodChannelMoAppUpdate].
  static MoAppUpdatePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MoAppUpdatePlatform] when
  /// they register themselves.
  static set instance(MoAppUpdatePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

}
