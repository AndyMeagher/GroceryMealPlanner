//
//  RecipeDetail.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.title2)
                            .bold()
                        
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                Text(ingredient.quantity)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                        
                        Text(recipe.instructions.isEmpty ? "No instructions provided" : recipe.instructions)
                            .foregroundStyle(recipe.instructions.isEmpty ? .secondary : .primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Created:")
                                .foregroundStyle(.secondary)
                            Text(recipe.createdAt, style: .date)
                        }
                        .font(.caption)
                        
                        HStack {
                            Text("Last updated:")
                                .foregroundStyle(.secondary)
                            Text(recipe.updatedAt, style: .relative)
                        }
                        .font(.caption)
                    }
                    .padding(.top)
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
}
