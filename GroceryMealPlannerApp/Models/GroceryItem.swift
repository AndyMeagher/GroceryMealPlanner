//
//  GroceryItem.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation
import SwiftData

@Model
class GroceryItem {
    var id: String
    var name: String
    var quantity: String
    var isChecked: Bool
    var createdAt: Date
    
    init(name: String, quantity: String, isChecked: Bool = false) {
        self.id = UUID().uuidString
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.createdAt = Date()
    }
}
