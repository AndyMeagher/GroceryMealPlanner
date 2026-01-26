//
//  AddWeekGroceryView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/25/26.
//

import SwiftUI

struct GroceryPickerView: View {

    let recipes: [Recipe]
    let onAdd: ([Ingredient]) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIngredients: Set<Ingredient> = []

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
                        }
                    }
                }
            }
            .navigationTitle("Add Groceries")
            .navigationBarTitleDisplayMode(.inline)
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

