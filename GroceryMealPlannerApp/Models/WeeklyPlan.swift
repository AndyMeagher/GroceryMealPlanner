//
//  WeeklyPlan.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation
import FirebaseFirestore

struct WeeklyPlan: Codable, Identifiable {
    @DocumentID var id: String?
    var weekOf: Date
    var meals: [DayOfWeek: PlannedMeal]
    let createdAt: Date
    var updatedAt: Date
    
    init(weekOf: Date,
         meals: [DayOfWeek: PlannedMeal] = [:],
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        
        self.weekOf = weekOf
        self.meals = meals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func thisWeeksRecipes(from allRecipes: [Recipe]) -> [Recipe] {
        let ids = Set(
            meals.values.compactMap {
                if case let .recipe(id) = $0 { return id }
                return nil
            }
        )
        return allRecipes.filter { ids.contains($0.id ?? "")}
    }
}
    
enum PlannedMeal: Codable, Equatable {
    case recipe(id: String?)
    case leftovers
    case takeout
    
    func stringValue() -> String {
        switch self {
        case .recipe(id: let id):
            return id ?? ""
        case .leftovers:
            return "leftovers"
        case .takeout:
            return "takeout"
        }
    }
    
    func displayText(recipes: [Recipe]) -> String {
        switch self {
        case .recipe(let id):
            return recipes.first(where: { $0.id == id })?.name ?? "Unknown Recipe"
        case .leftovers:
            return "Leftovers"
        case .takeout:
            return "Takeout"
        }
    }
}
