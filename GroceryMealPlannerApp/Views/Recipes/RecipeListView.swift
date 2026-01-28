//
//  RecipeListView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.isLoading && dataStore.recipes.isEmpty {
                    ProgressView("Loading recipes...")
                } else if dataStore.recipes.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("No Recipes Yet")
                                .font(AppFont.bold(size: 22))
                        } icon: {
                            Image(systemName: "book.closed")
                        }
                    } description: {
                        Text("Tap + to add your first recipe")
                            .font(AppFont.regular(size: 16))
                    }
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
                    dataStore.clearError()
                }
            } message: {
                Text(dataStore.errorMessage ?? "")
            }
        }
    }
    
    private var recipeList: some View {
        List {
            ForEach(dataStore.recipes) { recipe in
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                }
                .padding(.vertical, 4)
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
            await dataStore.deleteRecipe(recipe)
        }
    }
}
