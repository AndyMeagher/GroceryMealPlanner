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
    @State private var isFromCostco : Bool = false

    let onAdd: (GroceryItem) -> Void

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                    .accessibilityLabel("Item name")
                TextField("Quantity (optional)", text: $quantity)
                    .accessibilityLabel("Quantity")
                Toggle(isOn: $isFromCostco, label: {Text("Costco Item: ")})
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
                        Task{
                            let item = GroceryItem(
                                name: name,
                                quantity: quantity,
                                category: isFromCostco ? .costco : .unknown
                            )
                            onAdd(item)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
