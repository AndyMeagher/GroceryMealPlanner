//
//  OverlayWindow.swift
//  GroceryMealPlannerApp
//

import UIKit


final class OverlayWindow: UIWindow {
    var shouldBlockView = false
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if shouldBlockView { return self }
        return nil
    }
}
