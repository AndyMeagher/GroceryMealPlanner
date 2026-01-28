//
//  AddGroceryItemView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/25/26.
//

import SwiftUI

struct AddGroceryItemView: View {
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var quantity = ""
    let onAdd: (GroceryItem) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                    .accessibilityLabel("Item name")
                TextField("Quantity", text: $quantity)
                    .accessibilityLabel("Quantity")
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityHint("Closes this screen without adding an item")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = GroceryItem(
                            name: name,
                            quantity: quantity,
                        )
                        onAdd(item)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                    .accessibilityHint("Adds the grocery item to your list")
                }
            }
        }
    }
}
