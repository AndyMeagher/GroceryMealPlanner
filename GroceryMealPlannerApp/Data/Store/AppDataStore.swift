//
//  DataStore.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import Foundation
import FirebaseFirestore
import Combine

class AppDataStore: ObservableObject {
    
    // MARK: - Properties
    
    @Published var groceryItems: [GroceryItem]?
    @Published var recipes: [Recipe]?
    @Published var weeklyPlans: [WeeklyPlan]?
    @Published var errorMessage: String?
    
    var currentWeekPlan: WeeklyPlan? {
        weeklyPlans?.first
    }
    
    private let firestoreService: FirestoreServiceProtocol

    private var groceryListener: ListenerRegistration?
    private var recipeListener: ListenerRegistration?
    private var planListener: ListenerRegistration?
    
    
    init(service: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = service
        startistening()
    }
    
    deinit {
        stopListening()
    }
    
    private func startistening() {
        Task {
            do {
                try await firestoreService.ensureAuthenticated()
                startGroceryListener()
                startRecipeListener()
                startWeeklyPlanListener()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication failed. Please close and reopen the app."
                }
            }
        }
    }
    
    private func stopListening() {
        groceryListener?.remove()
        recipeListener?.remove()
        planListener?.remove()
    }
    
    // MARK: - Grocery Item Methods
    
    private func startGroceryListener() {
        groceryListener = firestoreService.observeGroceryItems(onUpdate: { groceryItems in
            DispatchQueue.main.async {
                self.groceryItems = groceryItems
            }
        }, onError: { errorMessage in
            DispatchQueue.main.async {
                self.errorMessage = errorMessage
                self.groceryItems = []
            }
        })
    }
    
    func addGroceryItem(_ item: GroceryItem) async {
        do {
            try await firestoreService.addGroceryItem(item)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to add grocery item: \(error.localizedDescription)"
            }
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
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete grocery item: \(error.localizedDescription)"
            }
        }
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async {
        do {
            try await firestoreService.addOrUpdateGroceryItems(with: ingredients)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to add ingredients to grocery list: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteAllCheckedGroceryItems() async {
        do {
            try await firestoreService.deleteAllCheckedGroceryItems()
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete checked items: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Recipe Methods
    
    private func startRecipeListener() {
        recipeListener = firestoreService.observeRecipes(onUpdate: { recipes in
            DispatchQueue.main.async {
                self.recipes = recipes
            }
        }, onError: { errorMessage in
            DispatchQueue.main.async {
                self.errorMessage = errorMessage
                self.recipes = []
            }
        })
    }
    
    func addRecipe(_ recipe: Recipe) async {
        do {
            try await firestoreService.addRecipe(recipe)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to add recipe: \(error.localizedDescription)"
            }
        }
    }
    
    func updateRecipe(_ recipe: Recipe) async {
        var updatedRecipe = recipe
        updatedRecipe.updatedAt = Date()
        await addRecipe(updatedRecipe)
    }
    
    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await firestoreService.deleteRecipe(recipe)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete recipe: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Weekly Plan Methods
    
    private func startWeeklyPlanListener() {
        planListener = firestoreService.observeWeeklyPlan(onUpdate: { weeklyPlans in
            DispatchQueue.main.async {
                self.weeklyPlans = weeklyPlans
            }
        }, onError: { errorMessage in
            DispatchQueue.main.async {
                self.errorMessage = errorMessage
                self.weeklyPlans = []
            }
        })
    }
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async {
        do {
            try await firestoreService.saveWeeklyPlan(plan)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save weekly plan: \(error.localizedDescription)"
            }
        }
    }
}
