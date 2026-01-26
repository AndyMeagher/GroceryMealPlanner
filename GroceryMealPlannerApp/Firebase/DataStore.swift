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

class FirebaseDataStore : ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var weeklyPlans: [WeeklyPlan] = []
    @Published var groceryItems: [GroceryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Only fetching current week
    var currentWeekPlan: WeeklyPlan? {
        weeklyPlans.first
    }
    
    private let db = Firestore.firestore()
    private var recipeListener: ListenerRegistration?
    private var planListener: ListenerRegistration?
    private var groceryListener: ListenerRegistration?
    
    init() {
        startListening()
        Task{
            do {
                if Auth.auth().currentUser == nil {
                    _ = try await Auth.auth().signInAnonymously()
                }
            }catch{
                print("Error authenticating:", error)
                errorMessage = "Failed to login into Firebase: \(error.localizedDescription)"
            }
        }
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
                
                if let error = error {
                    print("Recipe listener error:", error)
                    self.errorMessage = "Error loading recipes: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.recipes = []
                    return
                }
                
                self.recipes = documents.compactMap { doc in
                    self.parseRecipe(from: doc)
                }
                self.errorMessage = nil
            }
    }
    
    func addRecipe(_ recipe: Recipe) async {
        do {
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
            try await db.collection("recipes").document(recipe.slug).setData(data)
            errorMessage = nil
        } catch {
            print("Error adding recipe:", error)
            errorMessage = "Failed to add recipe: \(error.localizedDescription)"
        }
    }
    
    func updateRecipe(_ recipe: Recipe) async {
        var updatedRecie = recipe
        updatedRecie.updatedAt = Date()
        await addRecipe(updatedRecie)
    }
    
    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await db.collection("recipes").document(recipe.slug).delete()
            errorMessage = nil
        } catch {
            print("Error deleting recipe:", error)
            errorMessage = "Failed to delete recipe: \(error.localizedDescription)"
        }
    }
    
    private func parseRecipe(from doc: DocumentSnapshot) -> Recipe? {
        return FirebaseParser.parseRecipe(from: doc)
    }
    
    // MARK: - Weekly Plan Methods
    
    private func startWeeklyPlanListener() {
        let startOfWeek = Date().startOfWeek()

        planListener = db.collection("weeklyPlans")
            .whereField("weekOf", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Weekly plan listener error:", error)
                    self.errorMessage = "Error loading weekly plans: \(error.localizedDescription)"
                    return
                }
                
                guard let document = snapshot?.documents.first else { return }
                if let plan = self.parseWeeklyPlan(from: document) {
                    self.weeklyPlans = [plan]
                }
                self.errorMessage = nil
            }
    }
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async {
        do {
            var mealsDict: [String: String] = [:]
            for (day, meal) in plan.meals {
                mealsDict[day.rawValue] = meal.stringValue()
            }
            
            let data: [String: Any] = [
                "weekOf": Timestamp(date: plan.weekOf),
                "meals": mealsDict,
                "createdAt": Timestamp(date: plan.createdAt),
                "updatedAt": Timestamp(date: Date())
            ]
            
            try await db.collection("weeklyPlans").document(plan.slug).setData(data)
            errorMessage = nil
        } catch {
            print("Error saving weekly plan:", error)
            errorMessage = "Failed to save weekly plan: \(error.localizedDescription)"
        }
    }
    
    private func parseWeeklyPlan(from doc: DocumentSnapshot) -> WeeklyPlan? {
        return FirebaseParser.parseWeeklyPlan(from: doc)
    }
    
    // MARK: - Grocery Item Methods
    
    private func startGroceryListener() {
        groceryListener = db.collection("groceries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Grocery listener error:", error)
                    self.errorMessage = "Error loading groceries: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.groceryItems = []
                    return
                }
                
                self.groceryItems = documents.compactMap { self.parseGroceryItem(from: $0) }
                self.errorMessage = nil
            }
    }
    
    func addGroceryItem(_ item: GroceryItem) async {
        do {
            var data: [String: Any] = [
                "name": item.name,
                "isChecked": item.isChecked,
                "createdAt": Timestamp(date: item.createdAt),
                "updatedAt": Timestamp(date: item.updatedAt)
            ]
            if let quantity = item.quantity {
                data["quantity"] = quantity
            }
            try await db.collection("groceries").document(item.slug).setData(data, merge: true)
            errorMessage = nil
        } catch {
            print("Error adding grocery item:", error)
            errorMessage = "Failed to add grocery item: \(error.localizedDescription)"
        }
    }
    
    func updateGroceryItem(_ item: GroceryItem) async {
        var updatedItem = item
        updatedItem.updatedAt = Date()
        await addGroceryItem(updatedItem)
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async {
        do {
            try await db.collection("groceries").document(item.slug).delete()
            errorMessage = nil
        } catch {
            print("Error deleting grocery item:", error)
            errorMessage = "Failed to delete grocery item: \(error.localizedDescription)"
        }
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async {
        let batch = db.batch()
        
        for item in ingredients {
            let docRef = db.collection("groceries").document(item.slug)
            
            let data: [String: Any] = [
                "name": item.name,
                "isChecked": false,
                "quantity": item.quantity,
                "createdAt": Timestamp(date: .now),
                "updatedAt": Timestamp(date: .now)
            ]
            
            batch.setData(data, forDocument: docRef, merge: true)
        }
        
        do {
            try await batch.commit()
            print("All grocery items added/updated successfully!")
        } catch {
            errorMessage = "Failed to add ingredients to grocery list: \(error.localizedDescription)"
        }
    }
    
    func deleteAllCheckedGroceryItems() async {
        do {
            let snapshot = try await db.collection("groceries")
                .whereField("isChecked", isEqualTo: true)
                .getDocuments()
            
            guard !snapshot.documents.isEmpty else {
                print("No checked items to delete")
                return
            }

            let batch = db.batch()
            for doc in snapshot.documents {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()
            errorMessage = nil
        } catch {
            print("Error deleting checked items:", error)
            errorMessage = "Failed to delete checked items: \(error.localizedDescription)"
        }
    }
    
    private func parseGroceryItem(from doc: DocumentSnapshot) -> GroceryItem? {
        return FirebaseParser.parseGroceryItem(from: doc)
    }
}
