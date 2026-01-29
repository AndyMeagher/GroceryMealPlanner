//
//  RecipeDetail.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct RecipeDetailView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    @State private var isEditing = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ingredientSection
                    Divider()
                    instructionsSection
                    metadataSection
                }
                .padding()
            }
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(Color("Navy"))
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("Edit this recipe")

                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditRecipeView(recipe: recipe)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var ingredientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(AppFont.bold(size: 20))
            ForEach(recipe.ingredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.quantity)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("\(ingredient.name), quantity \(ingredient.quantity)")
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
            Text(recipe.instructions.isEmpty ? "No instructions provided" : recipe.instructions)
                .foregroundStyle(recipe.instructions.isEmpty ? .secondary : .primary)
                .accessibilityLabel(recipe.instructions.isEmpty ? "No instructions provided" : recipe.instructions)
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Created:")
                    .foregroundStyle(.secondary)
                Text(recipe.createdAt, style: .date)
            }
            .font(.caption)
        }
        .padding(.top)
    }
}
