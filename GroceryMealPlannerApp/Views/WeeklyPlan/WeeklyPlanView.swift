//
//  WeeklyPlanView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/22/26.
//

import SwiftUI

struct WeeklyPlanView: View {
    @Environment(FirebaseDataStore.self) private var dataStore
    
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
                            
                            if let recipeId = currentWeekPlan?.meals[day],
                               let recipe = recipes.first(where: { $0.id == recipeId }) {
                                Text(recipe.name)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    removeRecipe(for: day)
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
                RecipePickerView(recipes: recipes, day: day) { recipe in
                    assignRecipe(recipe, to: day)
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
    
    private func assignRecipe(_ recipe: Recipe, to day: DayOfWeek) {
        guard let plan = currentWeekPlan else { return }

        Task{
            do {
                plan.meals[day] = recipe.id
                try await dataStore.saveWeeklyPlan(plan)
            } catch{
                
            }
        }
       
    }
    
    private func removeRecipe(for day: DayOfWeek) {
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

struct RecipePickerView: View {
    let recipes: [Recipe]
    let day: DayOfWeek
    let onSelect: (Recipe) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                Button(action: {
                    onSelect(recipe)
                }) {
                    Text(recipe.name)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("Assign to \(day.rawValue)")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

