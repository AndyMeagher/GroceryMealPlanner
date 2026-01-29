//
//  EditRecipeView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct EditRecipeView: View {
    
    // MARK: Properties
    
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
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                nameSection
                instructionsSection
                instructionsSection
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
    
    // MARK: - Subviews
    
    private var nameSection: some View {
        Section("Recipe Name") {
            TextField("Name", text: $name)
                .accessibilityLabel("Recipe Name")
                .accessibilityHint("Enter the name of the recipe")
        }
    }
    
    private var instructionsSection: some View {
        Section("Instructions") {
            TextField("Instructions", text: $instructions, axis: .vertical)
                .lineLimit(5...10)
                .accessibilityLabel("Instructions")
                .accessibilityHint("Enter cooking instructions")
        }
    }
    
    private var ingredientListSection: some View {
        Section("Ingredients") {
            ForEach($ingredients) { $ingredient in
                HStack {
                    TextField("Ingredient", text: $ingredient.name)
                        .accessibilityLabel("Ingredient Name")
                        .accessibilityHint("Enter the ingredient name")
                    TextField("Amount", text: $ingredient.quantity)
                        .frame(width: 80)
                        .accessibilityLabel("Ingredient Amount")
                        .accessibilityHint("Enter the quantity for this ingredient")
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
            .accessibilityHint("Adds a new blank ingredient row")
        }
    }
    
    // MARK: - Methods
    
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
