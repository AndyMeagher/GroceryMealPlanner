//
//  WeeklyPlanView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI

struct WeeklyPlanView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedDayForPicker: DayOfWeek?
    @State private var showGroceryPickerView: Bool = false

    var allRecipes: [Recipe] {
        return dataStore.recipes.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    var thisWeeksRecipes: [Recipe]? {
        return dataStore.currentWeekPlan?.thisWeeksRecipes(from: allRecipes)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    Section("Week of: \(Date().startOfWeek().formatted(.dateTime.month().day()))") {
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
                                } else {
                                    Button("Assign Recipe") {
                                        selectedDayForPicker = day
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
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
                    .padding()
                }
            }
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
            .navigationTitle("This Week's Dinner")
            .onAppear {
                loadOrCreateWeeklyPlanIfNeeded()
            }
        }
    }
    
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
