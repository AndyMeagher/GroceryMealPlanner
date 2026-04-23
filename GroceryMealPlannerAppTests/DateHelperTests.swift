import Testing
import Foundation
@testable import GroceryMealPlannerApp

@Suite("Date.startOfWeek")
struct DateHelperTests {

    // Monday 2026-04-20
    private let knownMonday: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 20
        return Calendar.current.date(from: components)!
    }()

    @Test("startOfWeek() returns a Monday")
    func returnsMonday() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: knownMonday.startOfWeek())
        // weekday 2 = Monday in Gregorian calendar
        #expect(weekday == 2)
    }

    @Test("startOfWeek() on a Wednesday returns the preceding Monday")
    func wednesdayReturnsMonday() {
        let wednesday = Calendar.current.date(byAdding: .day, value: 2, to: knownMonday)!
        let result = wednesday.startOfWeek()
        #expect(Calendar.current.isDate(result, inSameDayAs: knownMonday))
    }

    @Test("startOfWeek() on a Sunday returns the Monday 6 days earlier")
    func sundayReturnsMonday() {
        let sunday = Calendar.current.date(byAdding: .day, value: 6, to: knownMonday)!
        let result = sunday.startOfWeek()
        #expect(Calendar.current.isDate(result, inSameDayAs: knownMonday))
    }

    @Test("startOfWeek() on a Monday returns the same day")
    func mondayReturnsSelf() {
        let result = knownMonday.startOfWeek()
        #expect(Calendar.current.isDate(result, inSameDayAs: knownMonday))
    }

    @Test("startOfWeek() strips the time component")
    func stripsTime() {
        let afternoon = Calendar.current.date(byAdding: .hour, value: 14, to: knownMonday)!
        let result = afternoon.startOfWeek()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: result)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }
}
