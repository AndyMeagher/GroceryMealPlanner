//
//  EditGroceryItemView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 3/16/26.
//


import SwiftUI

struct EditGroceryItemView: View {

    // MARK: Properties

    @Environment(AppDataStore.self) var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @Binding var groceryItem: GroceryItem

    @State private var name: String
    @State private var quantity: String
    @State private var category: GroceryCategory

    @State private var isSaving = false

    init(groceryItem: Binding<GroceryItem>) {
        _groceryItem = groceryItem
        _name = State(initialValue: groceryItem.wrappedValue.name)
        _quantity = State(initialValue: groceryItem.wrappedValue.quantity ?? "")
        _category = State(initialValue: groceryItem.wrappedValue.category)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                quantitytSection
                categorySection
            }
            .navigationTitle("Edit Grocery Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(isSaving)
                }
            }
        }
    }

    // MARK: - Subviews

    private var nameSection: some View {
        Section("Name") {
            TextField("Name", text: $name)
                .accessibilityLabel("Name")
                .accessibilityHint("Enter the name of the recipe")
        }
    }

    private var quantitytSection: some View {
        Section("Quantity") {
            TextField("Quantity", text: $quantity)
                .accessibilityLabel("Quantity")
                .accessibilityHint("Enter the quantity of items")
        }
    }

    private var categorySection: some View {
        Picker("Category", selection: $category) {
            ForEach(GroceryCategory.allCases.sorted {
                if $1 == .unknown { return true }
                if $0 == .unknown { return false }
                return $0.rawValue < $1.rawValue
            }, id: \.self) { category in
                Text(category.rawValue).tag(category)
            }
        }
    }

    // MARK: - Methods

    private func saveChanges() {
        isSaving = true

        groceryItem.name = name
        groceryItem.quantity = quantity
        groceryItem.category = category
        groceryItem.updatedAt = Date()

        Task {
            await dataStore.updateGroceryItem(groceryItem)
            isSaving = false
            dismiss()
        }
    }
}
