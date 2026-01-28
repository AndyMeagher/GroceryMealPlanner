//
//  EditRecipeView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct EditRecipeView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    
    @State private var name: String
    @State private var instructions: String
    @State private var ingredients: [Ingredient]
    @State private var isSaving = false
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _name = State(initialValue: recipe.name)
        _instructions = State(initialValue: recipe.instructions)
        _ingredients = State(initialValue: recipe.ingredients)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Name") {
                    TextField("Name", text: $name)
                }
                
                Section("Instructions") {
                    TextField("Instructions", text: $instructions, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Ingredients") {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            TextField("Ingredient", text: $ingredient.name)
                            TextField("Amount", text: $ingredient.quantity)
                                .frame(width: 80)
                        }
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                    
                    Button {
                        ingredients.append(Ingredient(name: "", quantity: ""))
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
    
    private func saveChanges() {
        isSaving = true
        
        var updatedRecipe = recipe
        updatedRecipe.name = name
        updatedRecipe.instructions = instructions
        updatedRecipe.ingredients = ingredients
        updatedRecipe.updatedAt = Date()
        
        Task {
            await dataStore.updateRecipe(updatedRecipe)
            isSaving = false
            dismiss()
        }
    }
}
