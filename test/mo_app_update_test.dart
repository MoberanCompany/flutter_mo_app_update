import 'package:flutter_test/flutter_test.dart';
import 'package:mo_app_update/mo_app_update.dart';
import 'package:mo_app_update/mo_app_update_platform_interface.dart';
import 'package:mo_app_update/mo_app_update_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMoAppUpdatePlatform
    with MockPlatformInterfaceMixin
    implements MoAppUpdatePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MoAppUpdatePlatform initialPlatform = MoAppUpdatePlatform.instance;

  test('$MethodChannelMoAppUpdate is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMoAppUpdate>());
  });

  test('getPlatformVersion', () async {
    MoAppUpdate moAppUpdatePlugin = MoAppUpdate();
    MockMoAppUpdatePlatform fakePlatform = MockMoAppUpdatePlatform();
    MoAppUpdatePlatform.instance = fakePlatform;

    expect(await moAppUpdatePlugin.getPlatformVersion(), '42');
  });
}
