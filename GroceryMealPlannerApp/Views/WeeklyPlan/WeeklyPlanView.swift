//
//  WeeklyPlanView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI

struct WeeklyPlanView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedDayForPicker: DayOfWeek?
    @State private var showGroceryPickerView: Bool = false
    
    var allRecipes: [Recipe] {
        return dataStore.recipes?.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        } ?? []
    }
    
    var thisWeeksRecipes: [Recipe]? {
        return dataStore.currentWeekPlan?.thisWeeksRecipes(from: allRecipes)
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            thisWeekList
                .navigationTitle("This Week's Dinner")
                .sheet(item: $selectedDayForPicker) { day in
                    MealPickerView(recipes: allRecipes, day: day) { plannedMeal in
                        assignMeal(plannedMeal, to: day)
                        selectedDayForPicker = nil
                    }
                }
                .sheet(isPresented: $showGroceryPickerView) {
                    if let assignRecipes = thisWeeksRecipes {
                        GroceryPickerView(recipes: assignRecipes) { itemsToAdd in
                            addIngredientsToGroceries(itemsToAdd)
                        }
                    }
                }
                .onAppear {
                    loadOrCreateWeeklyPlanIfNeeded()
                }
        }
    }
    
    // MARK: - Subviews
    
    private var thisWeekList: some View {
        List {
            Section{
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    HStack {
                        Text(day.displayName)
                            .font(AppFont.bold(size: 22))
                        Spacer()
                        if let meal = dataStore.currentWeekPlan?.meals[day] {
                            Text(meal.displayText(recipes: allRecipes))
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                removeMeal(for: day)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .accessibilityLabel("Remove meal for \(day.displayName)")
                        } else {
                            Button("Assign Recipe") {
                                selectedDayForPicker = day
                            }
                            .foregroundColor(.blue)
                            .accessibilityLabel("Assign a recipe for \(day.displayName)")
                        }
                    }
                }
            }
            header:{
                Text("Week of: \(Date().startOfWeek().formatted(.dateTime.month().day()))")
            }
            footer: {
                addGroceriesButton
            }
        }
    }
    
    @ViewBuilder
    private var addGroceriesButton: some View {
        if let assignedRecipes = thisWeeksRecipes, !assignedRecipes.isEmpty {
            Button {
                showGroceryPickerView = true
            } label: {
                VStack {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    Text("Add to Grocery List")
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Add ingredients to Grocery List")
            .padding()
        }
    }
    
    
    // MARK: - Methods
    
    private func loadOrCreateWeeklyPlanIfNeeded() {
        // Only create if it doesn't exist
        if dataStore.currentWeekPlan == nil {
            let newPlan = WeeklyPlan(weekOf: Date().startOfWeek())
            Task {
                await dataStore.saveWeeklyPlan(newPlan)
            }
        }
    }
    
    private func assignMeal(_ meal: PlannedMeal, to day: DayOfWeek) {
        guard var plan = dataStore.currentWeekPlan else { return }
        plan.meals[day] = meal
        Task {
            await dataStore.saveWeeklyPlan(plan)
        }
    }
    
    private func removeMeal(for day: DayOfWeek) {
        guard var plan = dataStore.currentWeekPlan else { return }
        plan.meals[day] = nil
        Task {
            await dataStore.saveWeeklyPlan(plan)
        }
    }
    
    private func addIngredientsToGroceries(_ items: [Ingredient]) {
        Task {
            await dataStore.addOrUpdateGroceryItems(with: items)
        }
    }
}

#Preview {
    WeeklyPlanView().environmentObject(AppDataStore(mode: .preview))
}
