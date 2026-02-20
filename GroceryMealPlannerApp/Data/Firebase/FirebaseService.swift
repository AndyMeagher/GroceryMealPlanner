//
//  FirebaseService.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/29/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirestoreServiceProtocol {
    
    func ensureAuthenticated() async throws
    
    func observeGroceryItems(
        onUpdate: @escaping ([GroceryItem]) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    
    func addGroceryItem(_ item: GroceryItem) async throws
    func updateGroceryItem(_ item: GroceryItem) async throws
    func deleteGroceryItem(_ item: GroceryItem) async throws
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async throws
    func deleteAllCheckedGroceryItems() async throws
        
    func observeRecipes(
        onUpdate: @escaping ([Recipe]) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    
    func addRecipe(_ recipe: Recipe) async throws
    func updateRecipe(_ recipe: Recipe) async throws
    func deleteRecipe(_ recipe: Recipe) async throws
        
    func observeWeeklyPlan(
        onUpdate: @escaping ([WeeklyPlan]) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async throws
}

class FirestoreService : FirestoreServiceProtocol {
    
    private let dataBase: Firestore = Firestore.firestore()
    
    // MARK: Authentication
    
    func ensureAuthenticated() async throws {
        if Auth.auth().currentUser == nil {
            _ = try await Auth.auth().signInAnonymously()
        }
    }
    
    // MARK: - Path configuration
    
    private var dataBasePath: String {
        if let householdKey = KeychainHelper.getItem("andys_household_key") {
            return "households/\(householdKey)"
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            fatalError("Firestore accessed before authentication completed")
        }
        return "users/\(uid)"
    }

    
    // MARK: - Grocery Items Methods
    
    func observeGroceryItems(
        onUpdate: @escaping ([GroceryItem]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        return dataBase.collection("\(dataBasePath)/groceries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading groceries: \(error.localizedDescription)")
                    return
                }
                
                let items = snapshot?.documents.compactMap {
                                FirebaseModelMapper.parseGroceryItem(from: $0)
                            } ?? []
                onUpdate(items)
            }
    }

    func addGroceryItem(_ item: GroceryItem) async throws {
        var data: [String: Any] = [
            "name": item.name,
            "isChecked": item.isChecked,
            "category": item.category.rawValue,
            "createdAt": Timestamp(date: item.createdAt),
            "updatedAt": Timestamp(date: item.updatedAt)
        ]
        if let quantity = item.quantity {
            data["quantity"] = quantity
        }
        try await dataBase.collection("\(dataBasePath)/groceries").document(item.slug).setData(data, merge: true)
    }

    func updateGroceryItem(_ item: GroceryItem) async throws  {
        var updatedItem = item
        updatedItem.updatedAt = Date()
        try await addGroceryItem(updatedItem)
    }

    func deleteGroceryItem(_ item: GroceryItem) async throws {
        try await dataBase.collection("\(dataBasePath)/groceries").document(item.slug).delete()
    }

    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async throws {
        var results: [GroceryItem] = []

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

            let groceryItem = GroceryItem(name: item.name, quantity: item.quantity, isChecked: false)
            results.append(groceryItem)
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

    // MARK: - Recipes
    
    func observeRecipes(
        onUpdate: @escaping ([Recipe]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        return dataBase.collection("\(dataBasePath)/recipes")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading recipes: \(error.localizedDescription)")
                    return
                }
                
                let items = snapshot?.documents.compactMap { doc in
                    FirebaseModelMapper.parseRecipe(from: doc)
                } ?? []
                onUpdate(items)
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

    // MARK: - WeeklyPlan
    
    func observeWeeklyPlan(
        onUpdate: @escaping ([WeeklyPlan]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        let startOfWeek = Date().startOfWeek()

        return dataBase.collection("\(dataBasePath)/weeklyPlans")
            .whereField("weekOf", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading weekly plans: \(error.localizedDescription)")
                    return
                }
                var weeklyPlans : [WeeklyPlan] = []
                if let document = snapshot?.documents.first,
                   let plan = FirebaseModelMapper.parseWeeklyPlan(from: document) {
                    weeklyPlans = [plan]
                }
                onUpdate(weeklyPlans)
            }
    }
    
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
