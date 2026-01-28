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
    
    var recipes : [Recipe] {
        return dataStore.recipes ?? []
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.recipes == nil {
                    ProgressView("Loading recipes...")
                } else if recipes.isEmpty {
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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("No recipes yet. Tap + to add your first recipe")
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
                    .tint(Color("Navy"))
                    .buttonStyle(.glassProminent)
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
                    DispatchQueue.main.async {
                        self.dataStore.errorMessage = nil
                    }
                }
            } message: {
                Text(dataStore.errorMessage ?? "")
            }
        }
    }
    
    private var recipeList: some View {
        List {
            ForEach(recipes) { recipe in
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedRecipe = recipe
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(recipe.name)
                .accessibilityHint("Double tap to view recipe details")
                .accessibilityAction(named: "Delete") {
                    deleteRecipe(recipe)
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

#Preview {
    RecipeListView().environmentObject(AppDataStore(mode: .preview))
}
