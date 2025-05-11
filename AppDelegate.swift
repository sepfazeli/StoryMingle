//
//  AppDelegate.swift
//  StoryMingle
//

import UIKit
import FirebaseCore
import FirebaseAppCheck
import FirebaseMessaging
import FirebaseAuth
import UserNotifications

// Notification for when APNs token is ready
extension Notification.Name {
    static let apnsTokenReady = Notification.Name("apnsTokenReady")
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: — App Launch

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("[AppDelegate] Launch time: \(Date())")

        // 1️⃣ Initialize Firebase
        FirebaseApp.configure()

        // 2️⃣ (Optional) App Check / disable app-verification in DEBUG
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif

        // 3️⃣ Register for APNs
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("🔔 Push Authorization Error:", error.localizedDescription)
                }
            }

        // 4️⃣ FCM delegate
        Messaging.messaging().delegate = self

        return true
    }

    // MARK: — APNs Token Received

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("[APNs] Token received at \(Date())")

        // Pass to FCM
        Messaging.messaging().apnsToken = deviceToken

        // Pass to FirebaseAuth (Phone Auth needs this)
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif

        // Notify SwiftUI that APNs token is ready
        NotificationCenter.default.post(name: .apnsTokenReady, object: nil)
    }

    // MARK: — Incoming Remote Notifications

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Give FirebaseAuth first crack at Phone-Auth notifications
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }

        // Otherwise your own handling…
        completionHandler(.newData)
    }

    // MARK: — UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
    }
}

// MARK: — MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("🔥 FCM token:", token)
        }
    }
}

// MARK: — UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Show banners/sounds even if app is foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
          @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
