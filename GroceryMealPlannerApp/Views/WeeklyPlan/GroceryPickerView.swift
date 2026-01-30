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
            recipeIngedientList
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
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var recipeIngedientList : some View {
        if recipes.isEmpty {
            ContentUnavailableView {
                Label {
                    Text("No Recipes Assigned This Week")
                        .font(AppFont.bold(size: 22))
                } icon: {
                    Image(systemName: "book")
                }
            } description: {
                Text("Assign a recipe to a day and add ingredients from it to your grocery list.")
                    .font(AppFont.regular(size: 16))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("No recipes assigned to this week yet. Assign a recipe to a day and add ingredients from it to your grocery list.")
        }else{
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

