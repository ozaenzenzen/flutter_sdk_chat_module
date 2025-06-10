import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:konnek_native_core/src/support/device_info_data_entity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class AppDeviceInfoCS {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  static DeviceInfoData? deviceInfoData;

  Future<DeviceInfoData> getDeviceData() async {
    String deviceId;
    String deviceName;
    String deviceType;
    String osVersion;

    // Get Device Information
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      deviceId = webBrowserInfo.productSub ?? const Uuid().v4();
      deviceName = "${webBrowserInfo.appCodeName} ${webBrowserInfo.appName} ${webBrowserInfo.appVersion}";
      deviceType = "Web";
      osVersion = "${webBrowserInfo.appVersion}";
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Android ID or generate a UUID
        deviceName = androidInfo.model;
        deviceType = "Android";
        osVersion = "Android ${androidInfo.version.release}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? const Uuid().v4(); // iOS Device ID or generate a UUID
        deviceName = iosInfo.utsname.machine;
        deviceType = "iOS";
        osVersion = "iOS ${iosInfo.systemVersion}";
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.id;
        deviceName = linuxInfo.name;
        deviceType = "Linux";
        osVersion = "Linux ${linuxInfo.version}";
      } else {
        deviceId = const Uuid().v4();
        deviceName = "Unknown Device";
        deviceType = "Unknown";
        osVersion = "Unknown OS";
      }
    }

    // Get App Version
    final packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;

    // Get Push Token for Push Notifications
    // String? pushToken = await firebaseMessaging.getToken();

    // Get Current Time for RegisteredAt
    String registeredAt = DateTime.now().toIso8601String();

    DeviceInfoData result = DeviceInfoData(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      osVersion: osVersion,
      appVersion: appVersion,
      registeredAt: registeredAt,
      randomIdentifier: const Uuid().v4(),
    );
    deviceInfoData = result;
    return result;
  }
}
