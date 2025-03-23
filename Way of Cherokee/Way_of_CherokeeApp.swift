import SwiftUI

@main
struct Way_of_CherokeeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        let isHorizontalLock = OrientationManager.shared.isHorizontalLock
        print(OrientationManager.shared.isHorizontalLock)
        if OrientationManager.shared.isHorizontalLock {
            return .landscape
        } else {
            return .allButUpsideDown
        }
    }
}
