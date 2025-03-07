import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static late String appName;
  static late String packageName;
  static late String version;
  static late String buildNumber;

  static const String apiBaseUrl = 'https://www.swiftride.tech/api/';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String userEndpoint = '/users';

  // App Settings
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Cache Settings
  static const int cacheMaxAge = 7; // days
  static const int cacheMaxSize = 50; // MB

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Build Configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Determine if we're in debug mode
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static Future<void> initialize() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing AppConfig: $e');
      }
      // Fallback values
      appName = 'Rydex';
      packageName = 'com.rydex.mobile';
      version = '1.0.0';
      buildNumber = '1';
    }
  }
}
