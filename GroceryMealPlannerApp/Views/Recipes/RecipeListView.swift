//
//  RecipeListView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import SwiftUI

struct RecipeListView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: Recipe?
    
    var recipes : [Recipe] {
        return dataStore.recipes ?? []
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .background(Color(.systemGray6))
                .navigationTitle("Our Recipes")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddRecipe = true
                        } label: {
                            Label("Add Recipe", systemImage: "plus")
                        }
                        .modifier(
                            iOS26ButtonStyle()
                        )
                    }
                }
                .sheet(isPresented: $showingAddRecipe) {
                    AddRecipeView()
                }
                .sheet(item: $selectedRecipe) { recipe in
                    if let binding = dataStore.bindingForRecipe(id: recipe.id){
                        RecipeDetailView(recipe: binding)
                    }
                }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var content: some View {
        if dataStore.recipes == nil {
            ProgressView("Loading recipes...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    private var recipeList: some View {
        List {
            ForEach(recipes) { recipe in
                Button {
                    selectedRecipe = recipe
                } label: {
                    HStack {
                        Text(recipe.name)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.white)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteRecipe(recipe)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityAction(named: "Delete") {
                    deleteRecipe(recipe)
                }
            }
        }.safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 16)
        }
    }
    
    // MARK: - Methods
    private func deleteRecipe(_ recipe: Recipe) {
        Task {
            await dataStore.deleteRecipe(recipe)
        }
    }
}

#Preview {
    RecipeListView().environmentObject(AppDataStore(service: MockFirestoreService()))
}
