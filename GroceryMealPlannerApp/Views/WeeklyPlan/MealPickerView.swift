//
//  MealPickerView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/25/26.
//

import SwiftUI

struct MealPickerView: View {
    let recipes: [Recipe]
    let day: DayOfWeek
    let onSelect: (PlannedMeal) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select a recipe")) {
                    ForEach(recipes) { recipe in
                        Button(action: {
                            self.onSelect(.recipe(id: recipe.id))
                            self.dismiss()
                        }) {
                            Text(recipe.name)
                        }
                    }
                }
                
                Section(header: Text("or:")) {
                    Button(action: {
                        self.onSelect(.leftovers)
                        self.dismiss()
                    }) {
                        Text("Leftovers")
                    }
                    Button(action: {
                        self.onSelect(.takeout)
                        self.dismiss()
                    }) {
                        Text("Takeout")
                    }
                }
            }
            .navigationTitle("Assign to \(day.rawValue)")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
