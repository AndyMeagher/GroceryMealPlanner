//
//  MockFirebaseService.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/29/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Used for Full Integration UI Tests and SwiftUI Previews without hitting Firebase

final class MockFirestoreService: FirestoreServiceProtocol {
    
    var groceryItems: [GroceryItem] = []
    var recipes: [Recipe] = []
    var weeklyPlans: [WeeklyPlan] = []

    func observeGroceryItems(
        onUpdate: @escaping ([GroceryItem]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        onUpdate(groceryItems)
        return nil
    }
    
    func addGroceryItem(_ item: GroceryItem) async throws{
        groceryItems.append(item)
    }
    
    func updateGroceryItem(_ item: GroceryItem) async throws {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index] = item
        }
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async throws {
        groceryItems.removeAll { $0.id == item.id }
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async throws  {
        let items = ingredients.map { Ingredient in
            GroceryItem(name: Ingredient.name, quantity: Ingredient.quantity, isChecked: false)
        }
        groceryItems.append(contentsOf: items)
    }
    
    func deleteAllCheckedGroceryItems() async throws {
        groceryItems.removeAll { $0.isChecked }
    }
        
    func observeRecipes(
        onUpdate: @escaping ([Recipe]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        onUpdate(recipes)
        return nil
    }
    
    func addRecipe(_ recipe: Recipe) async throws {
        recipes.append(recipe)
    }
    
    func updateRecipe(_ recipe: Recipe) async throws {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) async throws {
        recipes.removeAll { $0.id == recipe.id }
    }
    
    func observeWeeklyPlan(
        onUpdate: @escaping ([WeeklyPlan]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        onUpdate(weeklyPlans)
        return nil
    }
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async throws  {
        weeklyPlans.append(plan)
    }
}
