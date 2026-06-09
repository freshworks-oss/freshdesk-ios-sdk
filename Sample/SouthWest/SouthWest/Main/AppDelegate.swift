//
//  AppDelegate.swift
//  SouthWest
//
//  Created by Shahebaz Shaikh on 21/11/23.
//

import Foundation
import SwiftUI
import FreshdeskSDK

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initializeFreshworksSDK()
        registerNotifications()
        initialSetup()
        return true
    }
    
    private func initialSetup() {
        KeyboardObserver.shared.startObserving()
    }
    
    func initializeFreshworksSDK() {
        // Load any developer-entered ContentConfiguration from a previous run so that
        // localisation overrides set in the sample app survive across launches and
        // are applied at SDK init time (not only at runtime via setContentConfiguration).
        let configuration = Configuration(content: UserDefaults.standard.sampleContentConfiguration ?? ContentConfiguration())

        if var sdkConfig = UserDefaults.standard.getSDKConfig() {
            sdkConfig.config = configuration
            Freshdesk.initialize(with: sdkConfig)
        } else {
            let sdkConfig = FreshdeskSDKConfig(token: Configurations.Account.token,
                                               host: Configurations.Account.host,
                                               sdkId: Configurations.Account.sdkId,
                                               jwtToken: Configurations.Account.jwt,
                                               locale: Configurations.Account.locale,
                                               config: configuration,
                                               shouldEnableLogs: true
            )

            Freshdesk.initialize(with: sdkConfig)
            UserDefaults.standard.updateSDKConfig(sdkConfig, locale: Configurations.Account.locale)
        }
        Freshdesk.enableDebugLogs(true)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Handle authorization status
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("User Device Token: \(tokenString)")
        Freshdesk.setPushRegistrationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register device token")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let appState = UIApplication.shared.applicationState
        
        if Freshdesk.isFreshdeskNotification(userInfo) {
            Freshdesk.handleRemoteNotification(userInfo, appState: appState)
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let appState = UIApplication.shared.applicationState
        
        if Freshdesk.isFreshdeskNotification(userInfo) {
            Freshdesk.handleRemoteNotification(userInfo, appState: appState)
        
        } else {
            // Not freshworks notification, show normally
            completionHandler([.banner, .badge, .sound])
        }
    }
}
