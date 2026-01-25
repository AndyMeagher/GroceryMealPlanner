//
//  GlobalAlertToast.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/25/26.
//


import SwiftUI

struct GlobalAlertToast: View {
    @EnvironmentObject var dataStore: FirebaseDataStore
    @State private var showToast = false

    var body: some View {
        VStack {
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
            Spacer()
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
        dataStore.errorMessage = nil
    }
}
