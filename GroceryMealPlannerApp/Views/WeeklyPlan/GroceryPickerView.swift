//
//  AddWeekGroceryView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/25/26.
//

import SwiftUI

struct GroceryPickerView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIngredients: Set<Ingredient> = []
    
    let recipes: [Recipe]
    let onAdd: ([Ingredient]) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    Section(recipe.name) {
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text("\(ingredient.name) - \(ingredient.quantity)")
                                Spacer()
                                if selectedIngredients.contains(ingredient) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(for: ingredient)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(ingredient.name), \(ingredient.quantity)")
                            .accessibilityValue(selectedIngredients.contains(ingredient) ? "Selected" : "Not selected")
                        }
                    }
                }
            }
            .navigationTitle("Add Groceries")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let selected = Array(selectedIngredients)
                        onAdd(selected)
                        dismiss()
                    }
                    .disabled(selectedIngredients.isEmpty)
                    .accessibilityLabel("Add selected ingredients to grocery list")
                }
            }
        }
    }

    private func toggleSelection(for ingredient: Ingredient) {
        if selectedIngredients.contains(ingredient) {
            selectedIngredients.remove(ingredient)
        } else {
            selectedIngredients.insert(ingredient)
        }
    }
}

