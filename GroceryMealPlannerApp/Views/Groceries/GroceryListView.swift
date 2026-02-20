//
//  GroceryListView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI

struct GroceryListView: View {
    
    // MARK: - Properties
    
    @State private var showingAddItem = false
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @EnvironmentObject var dataStore: AppDataStore
    
    var groceryItems : [GroceryItem] {
        return dataStore.groceryItems ?? []
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
            .background(Color(.systemGray6))
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                    .modifier(
                        iOS26ButtonStyle()
                    )
                    .accessibilityLabel("Add Grocery Item")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear Checked") {
                        clearCheckedItems()
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddGroceryItemView{ item in
                    addNewItem(item: item)
                    
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var content: some View {
        if dataStore.groceryItems == nil {
            ProgressView("Loading Groceries...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if groceryItems.isEmpty {
            ContentUnavailableView {
                Label {
                    Text("No Groceries Yet")
                        .font(AppFont.bold(size: 22))
                } icon: {
                    Image(systemName: "cart")
                }
            } description: {
                Text("Tap + to add groceries")
                    .font(AppFont.regular(size: 16))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("No groceries yet. Tap + to add items.")
        } else {
            groceryList
        }

    }
    
    private var groceryList: some View {
        List {
            // Group items by category
            ForEach(GroceryCategory.allCases, id: \.self) { category in
                let itemsInCategory = groceryItems.filter { $0.category == category }
                // Only show section if there are items
                if !itemsInCategory.isEmpty {
                    Section(header:
                                Text(category.rawValue)
                        .foregroundStyle(.black)
                        .font(AppFont.bold(size: 22))
                    ) {
                        ForEach(itemsInCategory) { item in
                            Button(action: {
                                updateItemIsChecked(item: item)
                            }) {
                                HStack {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .strikethrough(item.isChecked)
                                            .foregroundColor(.primary)
                                        if let quantity = item.quantity, !quantity.isEmpty{
                                            Text(quantity)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .accessibilityElement(children: .combine)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.name)
                            .accessibilityValue(item.isChecked ? "Checked" : "Unchecked")
                            .accessibilityAction(named: "Delete") {
                                deleteItem(item: item)
                            }
                        }
                        .onDelete { offsets in
                            offsets.forEach { index in
                                let item = itemsInCategory[index]
                                deleteItem(item: item)
                            }
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 16)
        }
    }
    
    // MARK: Methods
    
    private func deleteItem(item: GroceryItem) {
        Task {
            await dataStore.deleteGroceryItem(item)
        }
    }
    
    private func clearCheckedItems() {
        Task{
            await dataStore.deleteAllCheckedGroceryItems()
        }
    }
    
    private func addNewItem(item: GroceryItem) {
        Task{
            await dataStore.addGroceryItem(item)
        }
    }
    
    private func updateItemIsChecked(item: GroceryItem) {
        Task{
            var updatedItem = item
            updatedItem.isChecked.toggle()
            await dataStore.updateGroceryItem(updatedItem)
        }
    }
}


#Preview {
    GroceryListView().environmentObject(AppDataStore(service: MockFirestoreService()))
}


