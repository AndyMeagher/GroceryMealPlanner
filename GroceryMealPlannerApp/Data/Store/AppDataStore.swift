//
//  DataStore.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import Foundation
import FirebaseFirestore
import Combine
import SwiftUI


@Observable
class AppDataStore {
    
    // MARK: - Properties
    
    var groceryItems: [GroceryItem]?
    var recipes: [Recipe]?
    var weeklyPlans: [WeeklyPlan]?
    var errorMessage: String?
    
    var currentWeekPlan: WeeklyPlan? {
        weeklyPlans?.first
    }
    
    private let firestoreService: FirestoreServiceProtocol

    private var groceryListener: ListenerRegistration?
    private var recipeListener: ListenerRegistration?
    private var planListener: ListenerRegistration?
    
    
    init(service: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = service
    }
    
    deinit {
        stopListening()
    }
    
    func startListening() {
        Task {
            do {
                try await firestoreService.ensureAuthenticated()
                startGroceryListener()
                startRecipeListener()
                startWeeklyPlanListener()
            } catch {
                setErrorMessage(message: "Authentication failed. Please close and reopen the app.")
            }
        }
    }
    
    private func stopListening() {
        groceryListener?.remove()
        recipeListener?.remove()
        planListener?.remove()
    }
    
    
    func setErrorMessage(message: String?){
        Task { @MainActor [weak self] in
            self?.errorMessage = message
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
