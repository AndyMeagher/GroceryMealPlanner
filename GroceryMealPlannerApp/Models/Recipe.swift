//
//  Recipe.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation

class Recipe: Identifiable {
    let id: String
    var name: String
    var instructions: String
    var ingredients: [Ingredient]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         instructions: String,
         ingredients: [Ingredient] = [],
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        
        self.id = id
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Ingredient: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var quantity: String
}
