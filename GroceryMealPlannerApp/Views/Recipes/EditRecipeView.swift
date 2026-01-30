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
    
    @Binding var recipe: Recipe
    
    @State private var name: String
    @State private var instructions: String
    @State private var ingredients: [Ingredient]
    @State private var isSaving = false
    
    init(recipe: Binding<Recipe>) {
        self._recipe = recipe
        _name = State(initialValue: recipe.wrappedValue.name)
        _instructions = State(initialValue: recipe.wrappedValue.instructions)
        _ingredients = State(initialValue: recipe.wrappedValue.ingredients)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                nameSection
                instructionsSection
                ingredientListSection
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
        
        recipe.name = name
        recipe.instructions = instructions
        recipe.ingredients = ingredients
        recipe.updatedAt = Date()
        
        Task {
            await dataStore.updateRecipe(recipe)
            isSaving = false
            dismiss()
        }
    }
}
