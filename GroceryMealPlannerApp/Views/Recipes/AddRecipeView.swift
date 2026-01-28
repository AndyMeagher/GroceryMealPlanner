//
//  AddRecipeView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct AddRecipeView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var instructions = ""
    @State private var ingredients: [Ingredient] = []
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Name") {
                    TextField("e.g., Spaghetti Carbonara", text: $name)
                        .accessibilityLabel("Recipe Name")
                        .accessibilityHint("Enter the name of your recipe")
                }
                
                Section("Instructions") {
                    TextField("How to make this recipe...", text: $instructions, axis: .vertical)
                        .lineLimit(5...10)
                        .accessibilityLabel("Instructions")
                        .accessibilityHint("Enter step-by-step cooking instructions")
                }
                
                Section {
                    ForEach(ingredients) { ingredient in
                        IngredientRowView(ingredient: ingredient) { updated in
                            if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                                ingredients[index] = updated
                            }
                        }
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
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                    .accessibilityHint("Discard this recipe and close")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(!canSave || isSaving)
                    .accessibilityHint("Save this new recipe")
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

struct IngredientRowView: View {
    let ingredient: Ingredient
    let onUpdate: (Ingredient) -> Void
    
    @State private var name: String
    @State private var quantity: String
    
    init(ingredient: Ingredient, onUpdate: @escaping (Ingredient) -> Void) {
        self.ingredient = ingredient
        self.onUpdate = onUpdate
        _name = State(initialValue: ingredient.name)
        _quantity = State(initialValue: ingredient.quantity)
    }
    
    var body: some View {
        HStack {
            TextField("Ingredient", text: $name)
                .onChange(of: name) { _, newValue in
                    updateIngredient()
                }
                .accessibilityLabel("Ingredient Name")
                .accessibilityHint("Enter the ingredient name")
            
            TextField("Qty", text: $quantity)
                .frame(width: 80)
                .onChange(of: quantity) { _, newValue in
                    updateIngredient()
                }
                .accessibilityLabel("Ingredient Quantity")
                .accessibilityHint("Enter the quantity for this ingredient")
        }
    }
    
    private func updateIngredient() {
        var updated = ingredient
        updated.name = name
        updated.quantity = quantity
        onUpdate(updated)
    }
}
