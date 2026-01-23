import SwiftUI

struct MainTabs: View {
    var body: some View {
        TabView {
//            GroceryListView()
//                .tabItem {
//                    Label("Groceries", systemImage: "cart")
//                }
            
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
            
            WeeklyPlanView()
                .tabItem {
                    Label("Weekly Plan", systemImage: "calendar")
                }
        }
    }
}
