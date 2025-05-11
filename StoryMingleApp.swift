//
//  StoryMingleApp.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07
//  Updated 2025-05-09 – no early Auth access; logging level only
//

import SwiftUI
import FirebaseCore        // FirebaseConfiguration

@main
struct StoryMingleApp: App {

    // Hooks UIKit AppDelegate (FirebaseApp.configure, FCM, APNs token, …)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authVM = AuthViewModel()

    // ───────────────────────────── One-time setup
    init() {
        // Silence verbose Firebase logs (socket chatter, etc.)
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        // **No call to Auth here – FirebaseApp not configured yet**
    }

    // ───────────────────────────── UI root
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
        }
    }
}
