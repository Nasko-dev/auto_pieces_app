import Flutter
import UIKit
import UserNotifications
import OneSignalFramework

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Configuration OneSignal - remplace la config native
    // OneSignal sera initialisé par le code Flutter/Dart

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
