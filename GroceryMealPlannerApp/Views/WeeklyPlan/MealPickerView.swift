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
                        .accessibilityLabel("Assign \(recipe.name) to \(day.displayName)")
                        .accessibilityHint("Double tap to assign this recipe")
                    }
                }
                
                Section(header: Text("Alternative options:")) {
                    Button(action: {
                        self.onSelect(.leftovers)
                        self.dismiss()
                    }) {
                        Text("Leftovers")
                    }
                    .accessibilityLabel("Assign Leftovers to \(day.displayName)")
                    .accessibilityHint("Double tap to assign leftovers for this day")
                    Button(action: {
                        self.onSelect(.takeout)
                        self.dismiss()
                    }) {
                        Text("Takeout")
                    }
                    .accessibilityLabel("Assign Takeout to \(day.displayName)")
                    .accessibilityHint("Double tap to assign takeout for this day")
                }
            }
            .navigationTitle("Assign to \(day.rawValue)")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
