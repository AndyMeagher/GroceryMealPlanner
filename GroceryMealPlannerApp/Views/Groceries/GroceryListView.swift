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
    @EnvironmentObject var dataStore: FirebaseDataStore
    
    var body: some View {
        NavigationStack {
            Group{
                groceryList
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear Checked") {
                        clearCheckedItems()
                    }
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
            ForEach(dataStore.groceryItems) { item in
                HStack {
                    Button(action: {
                        updateItemIsChecked(item: item)
                    }) {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isChecked ? .green : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .strikethrough(item.isChecked)
                        if let quantity = item.quantity{
                            Text(quantity)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            .onDelete { offsets in
                offsets.forEach({ index in
                    let item = dataStore.groceryItems[index]
                    deleteItem(item: item)
                })
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
            item.isChecked.toggle()
            await dataStore.updateGroceryItem(item)
        }
    }
}
