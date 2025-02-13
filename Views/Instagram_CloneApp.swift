//
//  Instagram_CloneApp.swift
//  Instagram-Clone
//
//  Created by youssef ahmed on 10/11/2024.
//

import SwiftUI
import FirebaseCore


@main
struct Instagram_CloneApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var session = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(session)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Firebase...")
        FirebaseApp.configure()
        
        return true
    }
}
