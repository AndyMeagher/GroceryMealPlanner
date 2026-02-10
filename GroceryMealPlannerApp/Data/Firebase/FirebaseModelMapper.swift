//
//  DataParser.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/26/26.
//

import Foundation
import FirebaseFirestore

// Extend Firebase DocumentSnapshot to allow for easier testing
extension DocumentSnapshot: FirebaseDocument {}

protocol FirebaseDocument {
    var documentID: String { get }
    func data() -> [String: Any]?
}

struct FirebaseModelMapper {
    static func parseRecipe(from doc: FirebaseDocument) -> Recipe? {
        let data = doc.data()
        
        guard let name = data?["name"] as? String,
              let instructions = data?["instructions"] as? String,
              let ingredientsArray = data?["ingredients"] as? [[String: Any]],
              let createdAt = extractDate(from: data?["createdAt"]),
              let updatedAt = extractDate(from: data?["updatedAt"]) else {
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
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func parseWeeklyPlan(from doc: FirebaseDocument) -> WeeklyPlan? {
        let data = doc.data()
        
        guard let weekOfTimestamp = data?["weekOf"] as? Timestamp,
              let mealsDict = data?["meals"] as? [String: String],
              let createdAt = extractDate(from: data?["createdAt"]),
              let updatedAt = extractDate(from: data?["updatedAt"])  else {
            return nil
        }
        
        var meals: [DayOfWeek: PlannedMeal] = [:]
        for (dayString, mealId) in mealsDict {
            if let day = DayOfWeek(rawValue: dayString) {
                switch mealId {
                case "leftovers":
                    meals[day] = .leftovers
                case "takeout":
                    meals[day] = .takeout
                default:
                    meals[day] = .recipe(id: mealId)
                }
            }
        }
        
        return WeeklyPlan(
            id: doc.documentID,
            weekOf: weekOfTimestamp.dateValue(),
            meals: meals,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func parseGroceryItem(from doc: FirebaseDocument) -> GroceryItem? {
        let data = doc.data()
        
        guard let name = data?["name"] as? String,
              let isChecked = data?["isChecked"] as? Bool,
              let createdAt = extractDate(from: data?["createdAt"]),
              let updatedAt = extractDate(from: data?["updatedAt"])  else {
            return nil
        }
        
        let quantity = data?["quantity"] as? String
        let categoryString = data?["category"] as? String
        
        return GroceryItem(
            id: doc.documentID,
            name: name,
            quantity: quantity,
            isChecked: isChecked,
            categoryString: categoryString,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private static func extractDate(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        } else if let date = value as? Date {
            return date
        }
        return nil
    }
}
