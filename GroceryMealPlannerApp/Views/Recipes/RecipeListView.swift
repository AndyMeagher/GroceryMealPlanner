//
//  RecipeListView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct RecipeListView: View {
    @Environment(FirebaseDataStore.self) private var dataStore
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.isLoading && dataStore.recipes.isEmpty {
                    ProgressView("Loading recipes...")
                } else if dataStore.recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes Yet",
                        systemImage: "book.closed",
                        description: Text("Tap + to add your first recipe")
                    )
                } else {
                    recipeList
                }
            }
            .navigationTitle("Our Recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddRecipe = true
                    } label: {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .alert("Error", isPresented: .constant(dataStore.errorMessage != nil)) {
                Button("OK") {
                    dataStore.errorMessage = nil
                }
            } message: {
                Text(dataStore.errorMessage ?? "")
            }
        }
    }
    
    private var recipeList: some View {
        List {
            ForEach(dataStore.recipes) { recipe in
                RecipeRowView(recipe: recipe)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRecipe = recipe
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteRecipe(recipe)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    private func deleteRecipe(_ recipe: Recipe) {
        Task {
            do {
                try await dataStore.deleteRecipe(recipe)
            } catch {
                dataStore.errorMessage = "Failed to delete recipe: \(error.localizedDescription)"
            }
        }
    }
}

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}
