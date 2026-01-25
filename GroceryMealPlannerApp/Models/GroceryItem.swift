//
//  GroceryItem.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation

class GroceryItem:  Identifiable{
    let id: String
    var name: String
    var quantity: String?
    var isChecked: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         quantity: String? = nil,
         isChecked: Bool = false,
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
