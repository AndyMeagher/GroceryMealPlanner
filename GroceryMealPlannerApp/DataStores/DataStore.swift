//
//  DataStore.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@Observable
class FirebaseDataStore {
    
    var recipes: [Recipe] = []
    
    var weeklyPlans: [WeeklyPlan] = []
    // Only fetching current week's data
    var currentWeekPlan: WeeklyPlan? {
        weeklyPlans.first
    }
    
    var groceryItems: [GroceryItem] = []
    
    var isLoading = false
    var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var recipeListener: ListenerRegistration?
    private var planListener: ListenerRegistration?
    private var groceryListener: ListenerRegistration?
    
    init() {
        startListening()
    }
    
    deinit {
        stopListening()
    }
    
    private func startListening() {
        startRecipeListener()
        startWeeklyPlanListener()
        startGroceryListener()
    }
    
    private func stopListening() {
        recipeListener?.remove()
        planListener?.remove()
        groceryListener?.remove()
    }
    
    // MARK: - Recipe Methods
    
    private func startRecipeListener() {
        recipeListener = db.collection("recipes")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                guard let documents = snapshot?.documents else {
                    self.recipes = []
                    return
                }
                
                self.recipes = documents.compactMap { doc in
                    self.parseRecipe(from: doc)
                }
                
                print("Loaded \(self.recipes.count) recipes")
            }
    }
    
    func addRecipe(_ recipe: Recipe) async throws {
        let data: [String: Any] = [
            "name": recipe.name,
            "instructions": recipe.instructions,
            "ingredients": recipe.ingredients.map { [
                "id": $0.id,
                "name": $0.name,
                "quantity": $0.quantity
            ]},
            "createdAt": Timestamp(date: recipe.createdAt),
            "updatedAt": Timestamp(date: recipe.updatedAt)
        ]
        try await db.collection("recipes").document(recipe.id).setData(data)
    }
    
    func updateRecipe(_ recipe: Recipe) async throws {
        recipe.updatedAt = Date()
        try await addRecipe(recipe)
    }
    
    func deleteRecipe(_ recipe: Recipe) async throws {
        try await db.collection("recipes").document(recipe.id).delete()
    }
    
    // MARK: - Weekly Plan Methods
    
    private func startWeeklyPlanListener() {
        let startOfWeek = Date().startOfWeek()

        planListener = db.collection("weeklyPlans")
            .whereField("weekOf", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let document = snapshot?.documents.first else { return }
                if let plan = self.parseWeeklyPlan(from: document) {
                    self.weeklyPlans = [plan]
                }
            }
    }
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async throws {
        var mealsDict: [String: String] = [:]
        for (day, recipeId) in plan.meals {
            mealsDict[day.rawValue] = recipeId
        }
        
        let data: [String: Any] = [
            "weekOf": Timestamp(date: plan.weekOf),
            "meals": mealsDict,
            "createdAt": Timestamp(date: plan.createdAt),
            "updatedAt": Timestamp(date: Date())
        ]
        
        try await db.collection("weeklyPlans").document(plan.id).setData(data)
    }
    
    
    // MARK: - Grocery Item Methods
    
    private func startGroceryListener() {
        groceryListener = db.collection("groceryItems")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.groceryItems = documents.compactMap { self.parseGroceryItem(from: $0) }
            }
    }
    
    func addGroceryItem(_ item: GroceryItem) async throws {
        // Your implementation
    }
    
    func updateGroceryItem(_ item: GroceryItem) async throws {
        // Your implementation
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async throws {
        // Your implementation
    }
    
    private func parseRecipe(from doc: DocumentSnapshot) -> Recipe? {
        let data = doc.data()
        
        guard let name = data?["name"] as? String,
              let instructions = data?["instructions"] as? String,
              let ingredientsArray = data?["ingredients"] as? [[String: Any]],
              let createdTimestamp = data?["createdAt"] as? Timestamp,
              let updatedTimestamp = data?["updatedAt"] as? Timestamp else {
            return nil
        }
        
        let ingredients = ingredientsArray.compactMap { ingredientData -> Ingredient? in
            guard let id = ingredientData["id"] as? String,
                  let name = ingredientData["name"] as? String,
                  let quantity = ingredientData["quantity"] as? String else {
                return nil
            }
            return Ingredient(id: id, name: name, quantity: quantity)
        }
        
        return Recipe(
            id: doc.documentID,
            name: name,
            instructions: instructions,
            ingredients: ingredients,
            createdAt: createdTimestamp.dateValue(),
            updatedAt: updatedTimestamp.dateValue()
        )
    }
    
    private func parseWeeklyPlan(from doc: DocumentSnapshot) -> WeeklyPlan? {
        let data = doc.data()
        
        guard let weekOfTimestamp = data?["weekOf"] as? Timestamp,
              let mealsDict = data?["meals"] as? [String: String],
              let createdTimestamp = data?["createdAt"] as? Timestamp,
              let updatedTimestamp = data?["updatedAt"] as? Timestamp else {
            return nil
        }
        
        var meals: [DayOfWeek: String] = [:]
        for (dayString, recipeId) in mealsDict {
            if let day = DayOfWeek(rawValue: dayString) {
                meals[day] = recipeId
            }
        }
        
        return WeeklyPlan(
            id: doc.documentID,
            weekOf: weekOfTimestamp.dateValue(),
            meals: meals,
            createdAt: createdTimestamp.dateValue(),
            updatedAt: updatedTimestamp.dateValue()
        )
    }
    
    private func parseGroceryItem(from doc: DocumentSnapshot) -> GroceryItem? {
        // Your parsing code
        return nil
    }
}
