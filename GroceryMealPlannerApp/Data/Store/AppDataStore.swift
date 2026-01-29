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

enum DataStoreMode {
    case live
    case preview
    case test
}

class AppDataStore: ObservableObject {
    
    @Published var recipes: [Recipe]?
    @Published var weeklyPlans: [WeeklyPlan]?
    @Published var groceryItems: [GroceryItem]?
    @Published var errorMessage: String?
    
    var currentWeekPlan: WeeklyPlan? {
        weeklyPlans?.first
    }
    
    private let db = Firestore.firestore()
    private var recipeListener: ListenerRegistration?
    private var planListener: ListenerRegistration?
    private var groceryListener: ListenerRegistration?
    
    private let mode: DataStoreMode
    
    // MARK: - Path Configuration

    private var dataBasePath: String {
        if let householdKey = KeychainHelper.getItem("andys_household_key") {
            return "households/\(householdKey)"
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            return "users/unknown"
        }

        return "users/\(uid)"
    }
    
    init(mode: DataStoreMode = .live) {
        self.mode = mode
        
        guard mode == .live else {
            recipes = []
            weeklyPlans = []
            groceryItems = []
            return
        }
        
        authenticateIfNeeded()
    }
    
    private func authenticateIfNeeded() {
        Task {
            do {
                if Auth.auth().currentUser == nil {
                    _ = try await Auth.auth().signInAnonymously()
                }
                self.startListening()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to login into Firebase: \(error.localizedDescription)"
                }
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
        recipeListener = db.collection("\(dataBasePath)/recipes")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Recipe listener error:", error)
                        self.errorMessage = "Error loading recipes: \(error.localizedDescription)"
                        self.recipes = []
                        return
                    }
                    
                    self.recipes = snapshot?.documents.compactMap { doc in
                        FirebaseModelMapper.parseRecipe(from: doc)
                    } ?? []
                    
                    self.errorMessage = nil
                }
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
            try await db.collection("\(dataBasePath)/recipes").document(recipe.slug).setData(data)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error adding recipe:", error)
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
            try await db.collection("\(dataBasePath)/recipes").document(recipe.slug).delete()
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error deleting recipe:", error)
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete recipe: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Weekly Plan Methods
    
    private func startWeeklyPlanListener() {
        let startOfWeek = Date().startOfWeek()
        
        planListener = db.collection("\(dataBasePath)/weeklyPlans")
            .whereField("weekOf", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Weekly plan listener error:", error)
                        self.errorMessage = "Error loading weekly plans: \(error.localizedDescription)"
                        self.weeklyPlans = []
                        return
                    }
                    
                    if let document = snapshot?.documents.first,
                       let plan = FirebaseModelMapper.parseWeeklyPlan(from: document) {
                        self.weeklyPlans = [plan]
                    } else {
                        self.weeklyPlans = []
                    }
                    
                    self.errorMessage = nil
                }
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
            
            try await db.collection("\(dataBasePath)/weeklyPlans").document(plan.slug).setData(data)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error saving weekly plan:", error)
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save weekly plan: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Grocery Item Methods
    
    private func startGroceryListener() {
        groceryListener = db.collection("\(dataBasePath)/groceries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Grocery listener error:", error)
                        self.errorMessage = "Error loading groceries: \(error.localizedDescription)"
                        self.groceryItems = []
                        return
                    }
                    
                    self.groceryItems = snapshot?.documents.compactMap {
                        FirebaseModelMapper.parseGroceryItem(from: $0)
                    } ?? []
                    
                    self.errorMessage = nil
                }
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
            try await db.collection("\(dataBasePath)/groceries").document(item.slug).setData(data, merge: true)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error adding grocery item:", error)
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
            try await db.collection("\(dataBasePath)/groceries").document(item.slug).delete()
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error deleting grocery item:", error)
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete grocery item: \(error.localizedDescription)"
            }
        }
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async {
        let batch = db.batch()
        
        for item in ingredients {
            let docRef = db.collection("\(dataBasePath)/groceries").document(item.slug)
            
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
            DispatchQueue.main.async {
                self.errorMessage = "Failed to add ingredients to grocery list: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteAllCheckedGroceryItems() async {
        do {
            let snapshot = try await db.collection("\(dataBasePath)/groceries")
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
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error deleting checked items:", error)
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete checked items: \(error.localizedDescription)"
            }
        }
    }
}
