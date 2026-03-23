//
//  GroceryItem.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import Foundation
import FirebaseFirestore

struct GroceryItem: Identifiable, Codable{
    @DocumentID var id: String?
    var name: String
    var category: GroceryCategory
    var quantity: String?
    var isChecked: Bool
    let createdAt: Date
    var updatedAt: Date
    
    static func create(
        name: String,
        quantity: String? = nil,
        isChecked: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) async -> GroceryItem {
        let category = await GroceryCategorizer.category(for: name)
        return GroceryItem(
            name: name,
            category: category,
            quantity: quantity,
            isChecked: isChecked,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// Taken from Spoontacular API Aisle properties
enum GroceryCategory: String, CaseIterable, Codable {
    case baking                    = "Baking"
    case healthFoods               = "Health Foods"
    case spicesAndSeasonings       = "Spices and Seasonings"
    case pastaAndRice              = "Pasta and Rice"
    case bakeryBread               = "Bakery/Bread"
    case refrigerated              = "Refrigerated"
    case cannedAndJarred           = "Canned and Jarred"
    case frozen                    = "Frozen"
    case nutButtersJamsAndHoney    = "Nut butters, Jams, and Honey"
    case oilVinegarSaladDressing   = "Oil, Vinegar, Salad Dressing"
    case condiments                = "Condiments"
    case savorySnacks              = "Savory Snacks"
    case milkEggsOtherDairy        = "Milk, Eggs, Other Dairy"
    case ethnicFoods               = "Ethnic Foods"
    case teaAndCoffee              = "Tea and Coffee"
    case meat                      = "Meat"
    case gourmet                   = "Gourmet"
    case sweetSnacks               = "Sweet Snacks"
    case glutenFree                = "Gluten Free"
    case alcoholicBeverages        = "Alcoholic Beverages"
    case cereal                    = "Cereal"
    case nuts                      = "Nuts"
    case beverages                 = "Beverages"
    case produce                   = "Produce"
    case seafood                   = "Seafood"
    case cheese                    = "Cheese"
    case driedFruits               = "Dried Fruits"
    case grillingSupplies          = "Grilling Supplies"
    case bread                     = "Bread"
    case unknown                   = "Unknown"

    init(from string: String) {
        self = GroceryCategory(rawValue: string) ?? .unknown
    }
}
