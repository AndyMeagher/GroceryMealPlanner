//
//  Recipe.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var instructions: String
    var ingredients: [Ingredient]
    let createdAt: Date
    var updatedAt: Date
    
    init(name: String,
         instructions: String,
         ingredients: [Ingredient] = [],
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Ingredient: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var quantity: String
    
    var slug: String {
        return self.name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}

extension Ingredient {
    enum CodingKeys: String, CodingKey {
        case id, name, quantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.name = try container.decode(String.self, forKey: .name)
        self.quantity = try container.decode(String.self, forKey: .quantity)
    }
}

