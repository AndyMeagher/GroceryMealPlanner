//
//  GroceryMealPlannerAppApp.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import CoreML

class AppDelegate: NSObject, UIApplicationDelegate {
     func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions:
 [UIApplication.LaunchOptionsKey: Any]? = nil
     ) -> Bool {
         FirebaseApp.configure()
         return true
     }
 }

@main
struct GroceryMealPlannerApp: App {
    @State private var dataStore: AppDataStore
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        if ProcessInfo.processInfo.arguments.contains("uitesting") {
            _dataStore = State(wrappedValue: AppDataStore(service: MockFirestoreService()))
        } else {
            _dataStore = State(wrappedValue: AppDataStore())
        }
        AppAppearance.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                MainTabs()
                    .environment(\.font, AppFont.regular(size: 16))
                    .environment(dataStore)
                    .overlay(
                        GlobalAlertToast()
                            .environment(dataStore)
                    )
                    .task {
                        dataStore.startListening()
                    }
            }
            .onOpenURL { url in
                guard url.scheme == "groceryplanner",
                      url.host == "join",
                      let code = url.pathComponents.dropFirst().first else { return }
                Task { await dataStore.joinHousehold(code: code) }
            }
        }
    }
}
