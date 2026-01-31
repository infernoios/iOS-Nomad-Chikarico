
import Foundation
import OneSignalFramework

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setup(launchOptions: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func setup(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.initialize("e76e7c1f-a022-4906-98d0-deaae3b8bba5", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in })
    }
}
