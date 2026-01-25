//
//  WeeklyPlanView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI

struct WeeklyPlanView: View {
    @EnvironmentObject var dataStore: FirebaseDataStore    
    @State private var currentWeekPlan: WeeklyPlan?
    @State private var selectedDayForPicker: DayOfWeek?
    
    var recipes: [Recipe] {
        return dataStore.recipes.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Week of: \(Date().startOfWeek().formatted(.dateTime.month().day()))") {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        HStack {
                            Text(day.displayName)
                                .font(.headline)
                            
                            Spacer()
                            
                            if let meal = currentWeekPlan?.meals[day] {
                                Text(meal.displayText(recipes: recipes))
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
            .sheet(item: $selectedDayForPicker) { day in
                MealPickerView(recipes: recipes, day: day) { plannedMeal in
                    assignMeal(plannedMeal, to: day)
                    selectedDayForPicker = nil
                }
            }
            .navigationTitle("This Week's Dinner")
            .onAppear {
                loadOrCreateWeeklyPlan()
            }
        }
    }
    
    private func loadOrCreateWeeklyPlan() {
        let startOfWeek = Date().startOfWeek()
        if let existing = dataStore.currentWeekPlan{
            currentWeekPlan = existing
        } else {
            let newPlan = WeeklyPlan(weekOf: startOfWeek)
            currentWeekPlan = newPlan
        }
    }
    
    private func assignMeal(_ meal: PlannedMeal, to day: DayOfWeek) {
        guard let plan = currentWeekPlan else { return }
        Task{
            do {
                plan.meals[day] = meal
                try await dataStore.saveWeeklyPlan(plan)
            } catch{
                
            }
        }
    }
    
    private func removeMeal(for day: DayOfWeek) {
        guard let plan = currentWeekPlan else { return }
        Task{
            do {
                plan.meals[day] = nil
                try await dataStore.saveWeeklyPlan(plan)
            } catch{
                
            }
        }
    }
}
