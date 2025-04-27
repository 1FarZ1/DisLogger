import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceHelper {
  static Future<String> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;

      return 'Name ${info.device} Android ${info.model} (${info.manufacturer}) - SDK ${info.version.sdkInt}';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return 'iOS ${info.utsname.machine} - ${info.systemVersion}';
    } else {
      return 'Unknown Platform';
    }
  }
}