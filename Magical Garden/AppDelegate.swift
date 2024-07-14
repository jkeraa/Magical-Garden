//
//  AppDelegate.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 01/07/24.
//

import UIKit
import SwiftUI
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MetalLibLoader.initializeMetal()
        // Preload sound effects
               SoundManager.shared.preloadSoundEffects(soundNames: [
                   ("SFX_1", "wav"),
                   ("SFX_2", "wav"),
                   ("SFX_3", "wav"),
                   ("SFX_4", "wav"),
                   ("SFX_5", "wav"),
                   ("SFX_6", "wav"),
                   ("SFX_7", "wav"),
                   ("SFX_8", "wav"),
                   
               ])
        HapticFeedbackManager.shared.preloadHapticGenerators()
        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        // Set the delegate
        center.delegate = self
        
        let onBoardingView = OnBoardingView()
            .environmentObject(ARState())
            .environmentObject(SaveLoadState())
            .environmentObject(SessionSettings())
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: onBoardingView)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        // Release resources when the app closes
        
       // FileManager.default.clearTmpDirectory()
     //   FileManager.default.clearCacheDirectory()
        
      //  SoundManager.shared.clearCache()
       // HapticFeedbackManager.shared.clearCache()
    }
}
