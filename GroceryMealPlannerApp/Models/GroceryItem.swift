//
//  GroceryItem.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation

struct GroceryItem:  Identifiable{
    let id: String
    var name: String
    var category: GroceryCategory
    var quantity: String?
    var isChecked: Bool
    let createdAt: Date
    var updatedAt: Date
    
    var slug: String {
        return self.name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         quantity: String? = nil,
         isChecked: Bool = false,
         category: GroceryCategory = .Other,
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
    }
}

enum GroceryCategory: String, CaseIterable {
    case Pet_Supplies = "Pet Supplies"
    case Dairy_Eggs = "Dairy & Eggs"
    case Canned_Goods = "Canned Goods"
    case Pasta_Grains = "Pasta & Grains"
    case Pantry = "Pantry"
    case Snacks = "Snacks"
    case Produce = "Produce"
    case Deli = "Deli"
    case Bakery = "Bakery"
    case Condiments_Sauces = "Condiments & Sauces"
    case Beverages = "Beverages"
    case Frozen_Foods = "Frozen Foods"
    case Personal_Care = "Personal Care"
    case Meat_Seafood = "Meat & Seafood"
    case Household = "Household"
    case Other = "Other"
    
   
}
