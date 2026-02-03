
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
        OneSignal.initialize("1be0a385-9bee-4038-a71d-bc4100344917", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in })
    }
}
