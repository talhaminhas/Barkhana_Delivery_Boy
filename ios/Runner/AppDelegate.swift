import UIKit
import FirebaseCore
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      NSLog("%@", "before firebase")
    //if FirebaseApp.app() == nil {
        FirebaseApp.configure()
      NSLog("%@", "after firebase")
    //}
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
