//
//  AddGroceryItemView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/25/26.
//

import SwiftUI

struct AddGroceryItemView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = ""
    let onAdd: (GroceryItem) -> Void
    
    // MARK: - Body
    
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
                        dismiss()

                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = GroceryItem(
                            name: name,
                            quantity: quantity,
                        )
                        onAdd(item)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
