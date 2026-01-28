//
//  GroceryMealPlannerAppApp.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct GroceryMealPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dataStore = AppDataStore()
    
    init() {
        AppAppearance.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                MainTabs()
                    .environmentObject(dataStore)
                    .environment(\.font, AppFont.regular(size: 16))
                    .overlay(
                        GlobalAlertToast()
                            .environmentObject(dataStore)
                    )
            }
        }
    }
}
