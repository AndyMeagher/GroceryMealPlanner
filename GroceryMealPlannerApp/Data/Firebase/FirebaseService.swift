//
//  FirebaseService.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/29/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    private let dataBase: Firestore
    private var dataBasePath: String {
        if let householdKey = KeychainHelper.getItem("andys_household_key") {
            return "households/\(householdKey)"
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            return "users/unknown"
        }
        return "users/\(uid)"
    }
    
    
    
    init(dataBase: Firestore = Firestore.firestore()) {
        self.dataBase = dataBase
    }
    
    // MARK: - Grocery Items Methods

    func addGroceryItem(_ item: GroceryItem) async throws {
        var data: [String: Any] = [
            "name": item.name,
            "isChecked": item.isChecked,
            "createdAt": Timestamp(date: item.createdAt),
            "updatedAt": Timestamp(date: item.updatedAt)
        ]
        if let quantity = item.quantity {
            data["quantity"] = quantity
        }
        try await dataBase.collection("\(dataBasePath)/groceries").document(item.slug).setData(data, merge: true)
    }
    
    func updateGroceryItem(_ item: GroceryItem) async throws{
        var updatedItem = item
        updatedItem.updatedAt = Date()
        try await addGroceryItem(updatedItem)
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async throws{
        try await dataBase.collection("\(dataBasePath)/groceries").document(item.slug).delete()
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async throws {
        
        let batch = dataBase.batch()
        
        for item in ingredients {
            let docRef = dataBase.collection("\(dataBasePath)/groceries").document(item.slug)
            
            let data: [String: Any] = [
                "name": item.name,
                "isChecked": false,
                "quantity": item.quantity,
                "createdAt": Timestamp(date: .now),
                "updatedAt": Timestamp(date: .now)
            ]
            
            batch.setData(data, forDocument: docRef, merge: true)
        }
        try await batch.commit()
    }
    
    func deleteAllCheckedGroceryItems() async throws {
        let snapshot = try await dataBase.collection("\(dataBasePath)/groceries")
            .whereField("isChecked", isEqualTo: true)
            .getDocuments()
        
        guard !snapshot.documents.isEmpty else {
            print("No checked items to delete")
            return
        }
        
        let batch = dataBase.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }
    
    // MARK: - Recipe Methods
    
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
        try await dataBase.collection("\(dataBasePath)/recipes").document(recipe.slug).setData(data)
    }
    
    func updateRecipe(_ recipe: Recipe) async throws {
        var updatedRecipe = recipe
        updatedRecipe.updatedAt = Date()
        try await addRecipe(updatedRecipe)
    }
    
    func deleteRecipe(_ recipe: Recipe) async throws {
        try await dataBase.collection("\(dataBasePath)/recipes").document(recipe.slug).delete()
    }
    
    // MARK: - Weekly Plan Methods
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async throws {
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
        
        try await dataBase.collection("\(dataBasePath)/weeklyPlans").document(plan.slug).setData(data)
    }
    
    
}
