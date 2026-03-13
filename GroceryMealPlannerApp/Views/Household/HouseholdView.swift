//
//  HouseholdView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 2/24/26.
//

import SwiftUI

struct HouseholdView: View {

    @Environment(AppDataStore.self) var dataStore: AppDataStore

    @State private var inviteCode: String?
    @State private var isGeneratingCode = false
    @State private var joinCodeInput = ""
    @State private var isJoining = false

    var body: some View {
        NavigationStack {
            Form {
                shareSection
                joinSection
            }
            .navigationTitle("Household")
        }
    }

    // MARK: - Share Section

    private var shareSection: some View {
        Section {
            if let code = inviteCode {
                HStack {
                    Text(code)
                        .font(AppFont.bold(size: 24))
                        .tracking(4)
                    Spacer()
                    ShareLink(
                        item: URL(string: "groceryplanner://join/\(code)")!,
                        message: Text("Join my Grocery & Meal Planner household!")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .padding(.vertical, 4)
            } else {
                Button {
                    generateCode()
                } label: {
                    if isGeneratingCode {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Generating...")
                        }
                    } else {
                        Label("Invite Someone", systemImage: "person.badge.plus")
                    }
                }
                .disabled(isGeneratingCode)
            }
        } header: {
            Text("Share Household")
        } footer: {
            if inviteCode != nil {
                Text("This code expires in 72 hours. Share the link or have them enter the code manually.")
            }
        }
    }

    // MARK: - Join Section

    private var joinSection: some View {
        Group {
            Section {
                TextField("Enter invite code", text: $joinCodeInput)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
            } header: {
                Text("Join a Household")
            } footer: {
                Text("Enter a code from someone else to share their grocery lists and meal plans.")
            }

            Section {
                Button {
                    joinWithCode()
                } label: {
                    Group {
                        if isJoining {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text("Joining...")
                                    .font(AppFont.bold(size: 16))
                            }
                        } else {
                            Text("Join Household")
                                .font(AppFont.bold(size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("Navy"))
                .disabled(joinCodeInput.trimmingCharacters(in: .whitespaces).isEmpty || isJoining)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32))
            }
        }
    }

    // MARK: - Actions

    private func generateCode() {
        isGeneratingCode = true
        Task {
            let code = await dataStore.generateInviteCode()
            DispatchQueue.main.async {
                inviteCode = code
                isGeneratingCode = false
            }
        }
    }

    private func joinWithCode() {
        isJoining = true
        let code = joinCodeInput.trimmingCharacters(in: .whitespaces)
        Task {
            let success = await dataStore.joinHousehold(code: code)
            DispatchQueue.main.async {
                isJoining = false
                if success { joinCodeInput = "" }
            }
        }
    }
}

#Preview {
    HouseholdView()
        .environment(AppDataStore(service: MockFirestoreService()))
}
