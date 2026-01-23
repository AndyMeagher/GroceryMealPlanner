//
//  GroceryListView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI
import SwiftData

struct GroceryListView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \GroceryItem.createdAt) private var groceryItems: [GroceryItem]
//    
//    @State private var showingAddItem = false
//    @State private var newItemName = ""
//    @State private var newItemQuantity = ""
    
    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(groceryItems) { item in
//                    HStack {
//                        Button(action: {
//                            item.isChecked.toggle()
//                        }) {
//                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
//                                .foregroundColor(item.isChecked ? .green : .gray)
//                        }
//                        .buttonStyle(BorderlessButtonStyle())
//                        
//                        VStack(alignment: .leading) {
//                            Text(item.name)
//                                .strikethrough(item.isChecked)
//                            Text(item.quantity)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        Spacer()
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .navigationTitle("Grocery List")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showingAddItem = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Clear Checked") {
//                        clearCheckedItems()
//                    }
//                }
//            }
//            .sheet(isPresented: $showingAddItem) {
//                AddGroceryItemView(isPresented: $showingAddItem)
//            }
//        }
    }
    
//    private func deleteItems(at offsets: IndexSet) {
//        for index in offsets {
//            modelContext.delete(groceryItems[index])
//        }
//    }
//    
//    private func clearCheckedItems() {
//        for item in groceryItems where item.isChecked {
//            modelContext.delete(item)
//        }
//    }
}

struct AddGroceryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var addedBy = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                TextField("Quantity", text: $quantity)
                TextField("Added by (optional)", text: $addedBy)
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = GroceryItem(
                            name: name,
                            quantity: quantity,
                        )
                        modelContext.insert(item)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
