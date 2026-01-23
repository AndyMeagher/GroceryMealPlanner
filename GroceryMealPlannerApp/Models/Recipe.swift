//
//  Recipe.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation

@Observable
class Recipe: Identifiable {
    var id: String
    var name: String
    var instructions: String
    var ingredients: [Ingredient]
    
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, instructions: String, ingredients: [Ingredient] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
    
    // For Firestore decoding
    init(id: String, name: String, instructions: String, ingredients: [Ingredient], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Required for Codable
    enum CodingKeys: String, CodingKey {
        case id, name, instructions, ingredients, createdAt, updatedAt
    }
}

struct Ingredient: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var quantity: String
}
