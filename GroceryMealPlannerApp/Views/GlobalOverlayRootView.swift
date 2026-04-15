//
//  Untitled.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 4/15/26.
//



import SwiftUI

struct GlobalOverlayRootView: View {
    @Environment(AppDataStore.self) var dataStore: AppDataStore
    @State private var showToast: Bool = false
    
    var body: some View {
        VStack {
            if dataStore.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(.circular)
            }
            
            if showToast, let message = dataStore.errorMessage {
                Text(message)
                    .padding()
                    .background(Color.red.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        withAnimation {
                            hideToast()
                        }
                    }
            }
        }
        .onChange(of: dataStore.errorMessage) { _, newValue in
            guard newValue != nil else { return }
            withAnimation { showToast = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { hideToast() }
            }
        }
    }

    private func hideToast() {
        showToast = false
        DispatchQueue.main.async {
            self.dataStore.errorMessage = nil
        }
    }

   
}


#Preview {
    GlobalOverlayRootView()
        .environment(AppDataStore(service: MockFirestoreService()))
}
