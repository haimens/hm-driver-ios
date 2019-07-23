import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ENV.ONE_SIGNAL.APP_ID,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active {
            // Hide notification if at foreground
            completionHandler(.init())
            
            // Handle notification
            handleNotification(withUserInfo: notification.request.content.userInfo)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        // Remove received notification
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Handle notification
        handleNotification(withUserInfo: userInfo)
    }
    
    private func handleNotification(withUserInfo info: [AnyHashable : Any]) {
        // Notification type
        let customData = (info["custom"] as? NSDictionary)?["a"] as? NSDictionary
        guard let notificationType = customData?["type"] as? Int else {
            return
        }
        
        if UIApplication.shared.applicationState == .inactive {
            switch notificationType {
            case 1: // Sharing location                
                if let _ = HMViewControllerManager.shared.presentingViewController as? HMAuthViewController {
                    HMPushActionManager.shared.initAction = .locationSharing
                } else {
                    HMPushActionManager.shared.startLocationSharing()
                }
            case 2: // Fetch SMS
                // Customer Token
                guard let customerToken = customData?["customer_token"] as? String else { return }
                
                // Handle fetch messaging
                if let _ = HMViewControllerManager.shared.presentingViewController as? HMAuthViewController {
                    HMPushActionManager.shared.initAction = .fetchSMS(customerToken: customerToken)
                } else {
                    HMPushActionManager.shared.presentMessagingVC(withCustomerToken: customerToken)
                }
            default:
                return
            }
        } else if UIApplication.shared.applicationState == .active {
            switch notificationType {
            case 1: // Sharing location
                HMPushActionManager.shared.startLocationSharing()
            case 2: // Fetch SMS
                // Customer Token
                guard let customerToken = customData?["customer_token"] as? String else { return }
                
                // If presenting messaging vc, fetch.
                if let _ = HMViewControllerManager.shared.presentingViewController as? HMCustomerMessagingViewController {
                    HMPushActionManager.shared.fetchMessage(withCustomerToken: customerToken)
                } else {
                    // Prompt new message alert
                    HMPushActionManager.shared.newMessageAlert(withCustomerToken: customerToken)
                }
            default:
                return
            }
        }

    }
}
