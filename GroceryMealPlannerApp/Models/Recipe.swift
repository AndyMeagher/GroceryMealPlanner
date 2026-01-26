//
//  Recipe.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation

struct Recipe: Identifiable {
    let id: String
    var name: String
    var instructions: String
    var ingredients: [Ingredient]
    let createdAt: Date
    var updatedAt: Date
    
    var slug: String {
        return self.name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
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

struct Ingredient: Hashable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var quantity: String
    
    var slug: String {
        return self.name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}
