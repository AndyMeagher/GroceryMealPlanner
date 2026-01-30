//
//  CustomModifiers.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/30/26.
//
import SwiftUI

struct iOS26ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(Color("Navy"))
        } else {
            content
        }
    }
}
