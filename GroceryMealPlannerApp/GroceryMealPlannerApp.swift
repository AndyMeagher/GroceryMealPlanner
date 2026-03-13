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

@main
struct GroceryMealPlannerApp: App {
    @State private var dataStore: AppDataStore

    init() {
        FirebaseApp.configure()
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
            }
        }
    }
}
