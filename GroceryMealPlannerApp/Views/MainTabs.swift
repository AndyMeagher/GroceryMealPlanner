import SwiftUI

struct MainTabs: View {
    var body: some View {
        TabView {
            GroceryListView()
                .tabItem {
                    Label("Groceries", systemImage: "cart")
                }.accessibilityLabel("Groceries Tab")

            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }.accessibilityLabel("Recipes Tab")

            WeeklyPlanView()
                .tabItem {
                    Label("Weekly Plan", systemImage: "calendar")
                }.accessibilityLabel("Weekly Plan Tab")

            HouseholdView()
                .tabItem {
                    Label("Household", systemImage: "person.2")
                }.accessibilityLabel("Household Tab")
        }
    }
}
