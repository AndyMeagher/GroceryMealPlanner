//
//  Fonts.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/28/26.
//

import SwiftUI

struct AppFont {
    // SwiftUI Fonts
    static func regular(size: CGFloat) -> Font {
        .custom("Synonym-Regular", size: size)
    }
    
    static func bold(size: CGFloat) -> Font {
        .custom("Synonym-Bold", size: size)
    }
    
    // UIKit Fonts
    static func regularUIFont(size: CGFloat) -> UIFont {
        UIFont(name: "Synonym-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func boldUIFont(size: CGFloat) -> UIFont {
        UIFont(name: "Synonym-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

struct AppAppearance {
    static func configure() {
        configureNavigationBar()
        configureTabBar()
    }
    
    private static func configureNavigationBar() {
        let navAppearance = UINavigationBarAppearance()
        
        navAppearance.titleTextAttributes = [
            .font: AppFont.boldUIFont(size: 20),
            .foregroundColor: UIColor.label
        ]
        
        navAppearance.largeTitleTextAttributes = [
            .font: AppFont.boldUIFont(size: 34),
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
    
    private static func configureTabBar() {
        let tabAppearance = UITabBarAppearance()
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.regularUIFont(size: 12)
        ]
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.boldUIFont(size: 12)
        ]
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
