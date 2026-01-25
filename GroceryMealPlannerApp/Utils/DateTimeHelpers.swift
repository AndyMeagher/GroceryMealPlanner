//
//  DateTimeHelpers.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/23/26.
//

import Foundation

extension Date {
    func startOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday

        let components = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: self
        )

        return calendar.date(from: components) ?? self
    }
}

enum DayOfWeek: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var displayName: String {
        self.rawValue
    }
}
