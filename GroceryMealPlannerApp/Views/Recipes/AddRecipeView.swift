//
//  AddRecipeView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct AddRecipeView: View {
    
    // MARK: - Properties
    
    @Environment(AppDataStore.self) var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var importUrl = ""
    @State private var instructions = ""
    @State private var ingredients: [Ingredient] = []
    @State private var isSaving = false
    @State private var isImporting = false

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                parseFromUrl
                recipeNameSection
                ingredientsSection
                instructionsSection
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
    
    private var parseFromUrl: some View {
        Section("Import from URL:") {
            HStack{
                TextField("Recipe Url", text: $importUrl)
                    .accessibilityLabel("Recipe Url")
                Button("Import") {
                   importRecipe()
                }
                .modifier(
                    iOS26ButtonStyle()
                )
                .disabled(importUrl.isEmpty)
            }
        }
    }
    
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
    
    private func importRecipe() {
        Task{
            if let recipe = await dataStore.importFromUrl(importUrl){
                name = recipe.name
                ingredients = recipe.ingredients
                instructions = recipe.instructions
            }else{
                print("here")
            }
           
            
        }
    }
}


