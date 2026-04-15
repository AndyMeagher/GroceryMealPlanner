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
    @State private var overlayWindow: OverlayWindow?
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
                if dataStore.user != nil {
                    MainTabs()
                        .environment(\.font, AppFont.regular(size: 16))
                        .environment(dataStore)
                        .task {
                            dataStore.startListening()
                        }
                } else {
                    LoginView()
                        .environment(dataStore)
                }
            }
            .task {
                dataStore.configureAuthStateChanges()
                setupOverlayWindow()
            }
            .onChange(of: dataStore.isLoading) { _, isLoading in
                overlayWindow?.shouldBlockView = isLoading
            }
            .onOpenURL { url in
                guard url.scheme == "groceryplanner",
                      url.host == "join",
                      let code = url.pathComponents.dropFirst().first else { return }
                Task { await dataStore.joinHousehold(code: code) }
            }
        }
    }

    private func setupOverlayWindow() {
        guard overlayWindow == nil,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let window = OverlayWindow(windowScene: scene)
        window.shouldBlockView = dataStore.isLoading
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        let controller = UIHostingController(rootView: GlobalOverlayRootView().environment(dataStore))
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.isHidden = false
        overlayWindow = window
    }
    
    
}
