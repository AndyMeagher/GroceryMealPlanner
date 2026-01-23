//
//  WeeklyPlan.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation

@Observable
class WeeklyPlan: Identifiable {
    var id: String
    var weekOf: Date
    var meals: [DayOfWeek: String] // [dayOfWeek: recipeId]
    
    var createdAt: Date
    var updatedAt: Date
    
    init(weekOf: Date, meals: [DayOfWeek: String] = [:]) {
        self.id = UUID().uuidString
        self.weekOf = weekOf
        self.meals = meals
        
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
    
    // For Firestore decoding
    init(id: String, weekOf: Date, meals: [DayOfWeek: String], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.weekOf = weekOf
        self.meals = meals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum DayOfWeek: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var displayName: String {
        self.rawValue
    }
}
