//
//  PassthroughWindow.swift
//  GroceryMealPlannerApp
//

import UIKit

/// A UIWindow that forwards touches to the window below when the hit view
/// is just the root container (i.e. no toast content is visible).
final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hitView ? nil : hitView
    }
}
