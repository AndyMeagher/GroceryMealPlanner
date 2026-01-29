//
//  AddRecipeView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct AddRecipeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var instructions = ""
    @State private var ingredients: [Ingredient] = []
    @State private var isSaving = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                recipeNameSection
                instructionsSection
                ingredientsSection
            }
            .navigationTitle("New Recipe")
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
                        saveRecipe()
                    }
                    .disabled(!canSave || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var recipeNameSection: some View {
        Section("Recipe Name") {
            TextField("e.g., Spaghetti Carbonara", text: $name)
                .accessibilityLabel("Recipe Name")
        }
    }
    
    private var instructionsSection: some View {
        Section("Instructions") {
            TextField("How to make this recipe...", text: $instructions, axis: .vertical)
                .lineLimit(5...10)
                .accessibilityLabel("Instructions")
        }
    }
    
    private var ingredientsSection: some View {
        Section {
            ForEach($ingredients) { $ingredient in
                ingredientRow(ingredient: $ingredient)
            }
            .onDelete { indexSet in
                ingredients.remove(atOffsets: indexSet)
            }
            Button {
                addIngredient()
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Ingredients")
        } footer: {
            if ingredients.isEmpty {
                Text("Add at least one ingredient")
            }
        }
    }
    
    private func ingredientRow(ingredient: Binding<Ingredient>) -> some View {
          HStack {
              TextField("Ingredient", text: ingredient.name)
                  .accessibilityLabel("Ingredient Name")
              
              TextField("Qty", text: ingredient.quantity)
                  .frame(width: 80)
                  .accessibilityLabel("Ingredient Quantity")
          }
    }
    
    // MARK: - Methods
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !ingredients.isEmpty
    }
    
    private func addIngredient() {
        ingredients.append(Ingredient(name: "", quantity: ""))
    }
    
    private func saveRecipe() {
        isSaving = true
        
        let recipe = Recipe(
            name: name.trimmingCharacters(in: .whitespaces),
            instructions: instructions.trimmingCharacters(in: .whitespaces),
            ingredients: ingredients
        )
        
        Task {
            await dataStore.addRecipe(recipe)
            isSaving = false
            dismiss()
        }
    }
}


