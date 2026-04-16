//
//  DataStore.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
import SwiftUI
import AuthenticationServices


@Observable
class AppDataStore {
    
    // MARK: - Properties
    
    var user: User?
    var household: Household?
    var householdMembers: [UserProfile] = []
    
    var isHouseholdOwner: Bool {
        guard let uid = user?.uid, let household else { return false }
        return household.ownerId == uid
    }
    
    var groceryItems: [GroceryItem]?
    var recipes: [Recipe]?
    var weeklyPlans: [WeeklyPlan]?
    var errorMessage: String?
    var isLoading: Bool = false

    var currentWeekPlan: WeeklyPlan? {
        weeklyPlans?.first
    }
    
    private let firestoreService: FirestoreServiceProtocol
    
    private var groceryListener: ListenerRegistration?
    private var recipeListener: ListenerRegistration?
    private var planListener: ListenerRegistration?
    private var householdListener: ListenerRegistration?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle!
    
    
    init(service: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = service
    }
    
    deinit {
        stopListening()
        Auth.auth().removeStateDidChangeListener(authStateHandle)
    }
    
    func startListening() {
        guard groceryListener == nil, recipeListener == nil, planListener == nil else { return }
        Task {
            do {
                try await firestoreService.setupHousehold()
                startGroceryListener()
                startRecipeListener()
                startWeeklyPlanListener()
                startHouseholdListener()
            } catch {
                setErrorMessage(message: "Authentication failed. Please close and reopen the app.")
            }
        }
    }
    
    private func stopListening() {
        groceryListener?.remove()
        recipeListener?.remove()
        planListener?.remove()
        householdListener?.remove()
    }
    
    
    func setErrorMessage(message: String?){
        Task { @MainActor [weak self] in
            self?.errorMessage = message
        }
    }
    
    // MARK: - Auth State
    
    func configureAuthStateChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async {
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            setErrorMessage(message: "Apple Sign In failed: invalid token.")
            return
        }
        
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        do {
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            let displayName = credential.fullName?.givenName ?? credential.email ?? "User"
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            try await firestoreService.saveUserProfile(displayName: displayName)
            self.user = Auth.auth().currentUser
        } catch {
            setErrorMessage(message: "Sign in failed: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do{
            try Auth.auth().signOut()
        }catch{
            setErrorMessage(message: "Sign Out failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Grocery Item Methods
    
    private func startGroceryListener() {
        groceryListener = firestoreService.observeGroceryItems(
            onUpdate: { groceryItems in
                Task { @MainActor [weak self] in
                    self?.groceryItems = groceryItems
                }
            }, onError: { errorMessage in
                Task { @MainActor [weak self] in
                    self?.groceryItems = []
                    self?.setErrorMessage(message: errorMessage)
                }
            })
    }
    
    func addGroceryItem(_ item: GroceryItem) async {
        do {
            try await firestoreService.addGroceryItem(item)
            setErrorMessage(message: nil)
        } catch {
            setErrorMessage(message: "Failed to add grocery item: \(error.localizedDescription)")
        }
    }
    
    func updateGroceryItem(_ item: GroceryItem) async {
        var updatedItem = item
        updatedItem.updatedAt = Date()
        await addGroceryItem(updatedItem)
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async {
        do {
            try await firestoreService.deleteGroceryItem(item)
            self.setErrorMessage(message: nil)
        } catch {
            self.setErrorMessage(message: "Failed to delete grocery item: \(error.localizedDescription)")
        }
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async {
        do {
            try await firestoreService.addOrUpdateGroceryItems(with: ingredients)
            self.setErrorMessage(message: nil)
        } catch {
            self.setErrorMessage(message: "Failed to add ingredients to grocery list: \(error.localizedDescription)")
        }
    }
    
    func deleteAllCheckedGroceryItems() async {
        do {
            try await firestoreService.deleteAllCheckedGroceryItems()
            self.setErrorMessage(message: nil)
        } catch {
            self.setErrorMessage(message: "Failed to delete checked items: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Recipe Methods
    
    private func startRecipeListener() {
        recipeListener = firestoreService.observeRecipes(onUpdate: { recipes in
            Task { @MainActor [weak self] in
                self?.recipes = recipes
            }
        }, onError: { errorMessage in
            Task { @MainActor [weak self] in
                self?.setErrorMessage(message: errorMessage)
                self?.recipes = []
            }
        })
    }
    
    func addRecipe(_ recipe: Recipe) async {
        do {
            try await firestoreService.addRecipe(recipe)
            self.setErrorMessage(message: nil)
            
        } catch {
            self.setErrorMessage(message: "Failed to add recipe: \(error.localizedDescription)")
        }
    }
    
    func updateRecipe(_ recipe: Recipe) async {
        var updatedRecipe = recipe
        updatedRecipe.updatedAt = Date()
        await addRecipe(updatedRecipe)
    }
    
    func bindingForRecipe(id: Recipe.ID) -> Binding<Recipe>? {
        guard let recipes = recipes,
              let index = recipes.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        return Binding<Recipe>(
            get: {
                self.recipes![index]
            },
            set: { newValue in
                self.recipes![index] = newValue
            }
        )
    }
    
    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await firestoreService.deleteRecipe(recipe)
            self.setErrorMessage(message: nil)
        } catch {
            self.setErrorMessage(message: "Failed to delete recipe: \(error.localizedDescription)")
        }
    }
    
    func importFromUrl(_ string: String) async -> ImportedRecipe? {
        guard let url = URL(string: string),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme),
              url.host != nil else {
            self.setErrorMessage(message: "Invalid URL. Check the format and try again.")
            return nil
        }
        do{
            self.isLoading = true
            let importedRecipe = try await firestoreService.importRecipeFromUrl(url)
            self.isLoading = false
            return importedRecipe
        } catch {
            self.setErrorMessage(message: "Failed to import recipe: \(error.localizedDescription)")
            self.isLoading = false
            return nil
        }
    }
    
    // MARK: - Weekly Plan Methods
    
    private func startWeeklyPlanListener() {
        planListener = firestoreService.observeWeeklyPlan(onUpdate: { weeklyPlans in
            Task { @MainActor [weak self] in
                self?.weeklyPlans = weeklyPlans
            }
        }, onError: { errorMessage in
            Task { @MainActor [weak self] in
                self?.setErrorMessage(message: errorMessage)
                self?.weeklyPlans = []
            }
        })
    }
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async {
        do {
            try await firestoreService.saveWeeklyPlan(plan)
            self.setErrorMessage(message: nil)
        } catch {
            self.setErrorMessage(message: "Failed to save weekly plan: \(error.localizedDescription)")
        }
    }
    
    private func startHouseholdListener() {
        householdListener = firestoreService.observeHousehold(onUpdate: { [weak self] household in
            guard let self else { return }
            Task { @MainActor in
                self.household = household
                self.householdMembers = (try? await self.firestoreService.fetchHouseholdMembers(memberIds: household.members)) ?? []
            }
        }, onError: { [weak self] errorMessage in
            self?.setErrorMessage(message: errorMessage)
        })
    }
    
    // MARK: - Household Methods
    
    func generateInviteCode() async -> String? {
        do {
            return try await firestoreService.generateInviteCode()
        } catch {
            self.setErrorMessage(message: "Failed to generate invite code. \(error.localizedDescription)")
            return nil
        }
    }
    
    @discardableResult
    func joinHousehold(code: String) async -> Bool {
        do {
            try await firestoreService.joinHousehold(code: code)
            self.stopListening()
            self.groceryItems = nil
            self.recipes = nil
            self.weeklyPlans = nil
            self.startGroceryListener()
            self.startRecipeListener()
            self.startWeeklyPlanListener()
            
            return true
        } catch {
            self.setErrorMessage(message: "Invalid or expired invite code.")
            return false
        }
    }
}
