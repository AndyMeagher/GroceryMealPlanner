//
//  GroceryMealPlannerAppApp.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI
import SwiftData
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
    @State private var dataStore: FirebaseDataStore?  
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let dataStore = dataStore {
                    MainTabs()
                        .environment(dataStore)
                } else {
                    ProgressView("Loading...")
                }
            }
            .task {
                await initialize()
            }
        }
    }
    
    private func initialize() async {
        do {
            try await ensureSignedIn()
            // Create Store after Firebase has configured and Signed In
            if dataStore == nil {
                dataStore = FirebaseDataStore()
            }
        } catch {
            print("Sign-in error: \(error)")
        }
    }
    
    func ensureSignedIn() async throws {
        if Auth.auth().currentUser == nil {
            _ = try await Auth.auth().signInAnonymously()
        }
    }
}
