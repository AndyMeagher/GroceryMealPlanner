//
//  GroceryListView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI

struct GroceryListView: View {
    
    @State private var showingAddItem = false
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @EnvironmentObject var dataStore: AppDataStore
    
    var groceryItems : [GroceryItem] {
        return dataStore.groceryItems ?? []
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                Group{
                    if dataStore.groceryItems == nil {
                        ProgressView("Loading Groceries...")
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
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                    .tint(Color("Navy"))
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel("Add Grocery Item")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear Checked") {
                        clearCheckedItems()
                    }
                    .accessibilityHint("Removes all checked items from the list")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddGroceryItemView(isPresented: $showingAddItem) { item in
                    addNewItem(item: item)
                }
            }
        }
    }
    
    private var groceryList: some View {
        List {
            ForEach(groceryItems) { item in
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
                            if let quantity = item.quantity {
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
                .accessibilityHint("Double tap to toggle")
                .accessibilityAction(named: "Delete") {
                    deleteItem(item: item)
                }
            }
            .onDelete { offsets in
                offsets.forEach { index in
                    let item = groceryItems[index]
                    deleteItem(item: item)
                }
            }
        }
    }
    
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
    GroceryListView().environmentObject(AppDataStore(mode: .preview))
}


