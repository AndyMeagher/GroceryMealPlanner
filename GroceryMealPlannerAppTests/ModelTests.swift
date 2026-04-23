import Testing
@testable import GroceryMealPlannerApp
import Foundation

// MARK: - GroceryCategory

@Suite("GroceryCategory")
struct GroceryCategoryTests {

    @Test("init(from:) resolves known raw values")
    func initFromKnownString() {
        #expect(GroceryCategory(from: "Produce") == .produce)
        #expect(GroceryCategory(from: "Meat") == .meat)
        #expect(GroceryCategory(from: "Frozen") == .frozen)
    }

    @Test("init(from:) falls back to .unknown for unrecognized strings")
    func initFromUnknownString() {
        #expect(GroceryCategory(from: "Not A Real Category") == .unknown)
        #expect(GroceryCategory(from: "") == .unknown)
    }

    @Test("sortedCases places .unknown last")
    func sortedCasesUnknownLast() {
        #expect(GroceryCategory.sortedCases.last == .unknown)
    }

    @Test("sortedCases is alphabetically ordered (excluding .unknown)")
    func sortedCasesAlphabetical() {
        let withoutUnknown = GroceryCategory.sortedCases.dropLast()
        let names = withoutUnknown.map(\.rawValue)
        #expect(names == names.sorted())
    }

    @Test("sortedCases contains every case exactly once")
    func sortedCasesContainsAll() {
        #expect(GroceryCategory.sortedCases.count == GroceryCategory.allCases.count)
    }
}

// MARK: - Ingredient

@Suite("Ingredient")
struct IngredientTests {

    @Test("slug lowercases and replaces spaces with underscores")
    func slugMultiWord() {
        let ingredient = Ingredient(name: "Olive Oil", quantity: "2 tbsp")
        #expect(ingredient.slug == "olive_oil")
    }

    @Test("slug handles single-word names")
    func slugSingleWord() {
        let ingredient = Ingredient(name: "Basil", quantity: "1 cup")
        #expect(ingredient.slug == "basil")
    }

    @Test("slug lowercases uppercase input")
    func slugUppercase() {
        let ingredient = Ingredient(name: "ALL CAPS ITEM", quantity: "1")
        #expect(ingredient.slug == "all_caps_item")
    }
}

// MARK: - PlannedMeal

@Suite("PlannedMeal")
struct PlannedMealTests {

    @Test("stringValue() returns the recipe id")
    func stringValueRecipe() {
        #expect(PlannedMeal.recipe(id: "abc123").stringValue() == "abc123")
    }

    @Test("stringValue() returns empty string when recipe id is nil")
    func stringValueNilId() {
        #expect(PlannedMeal.recipe(id: nil).stringValue() == "")
    }

    @Test("stringValue() returns 'leftovers' for .leftovers")
    func stringValueLeftovers() {
        #expect(PlannedMeal.leftovers.stringValue() == "leftovers")
    }

    @Test("stringValue() returns 'takeout' for .takeout")
    func stringValueTakeout() {
        #expect(PlannedMeal.takeout.stringValue() == "takeout")
    }

    @Test("displayText() returns the matched recipe name")
    func displayTextMatchingRecipe() {
        var recipe = Recipe(name: "Pasta Carbonara", instructions: "")
        recipe.id = "pasta1"
        let meal = PlannedMeal.recipe(id: "pasta1")
        #expect(meal.displayText(recipes: [recipe]) == "Pasta Carbonara")
    }

    @Test("displayText() returns 'Unknown Recipe' when id has no match")
    func displayTextNoMatch() {
        var recipe = Recipe(name: "Pasta", instructions: "")
        recipe.id = "pasta1"
        let meal = PlannedMeal.recipe(id: "different-id")
        #expect(meal.displayText(recipes: [recipe]) == "Unknown Recipe")
    }

    @Test("displayText() returns 'Leftovers' for .leftovers")
    func displayTextLeftovers() {
        #expect(PlannedMeal.leftovers.displayText(recipes: []) == "Leftovers")
    }

    @Test("displayText() returns 'Takeout' for .takeout")
    func displayTextTakeout() {
        #expect(PlannedMeal.takeout.displayText(recipes: []) == "Takeout")
    }
}

// MARK: - WeeklyPlan

@Suite("WeeklyPlan")
struct WeeklyPlanTests {

    private func makeRecipe(id: String, name: String) -> Recipe {
        var recipe = Recipe(name: name, instructions: "")
        recipe.id = id
        return recipe
    }

    @Test("thisWeeksRecipes() returns only recipes scheduled in the plan")
    func returnsScheduledRecipes() {
        let pasta = makeRecipe(id: "r1", name: "Pasta")
        let salad = makeRecipe(id: "r2", name: "Salad")
        let soup  = makeRecipe(id: "r3", name: "Soup")

        let plan = WeeklyPlan(
            weekOf: .now,
            meals: [.monday: .recipe(id: "r1"), .wednesday: .recipe(id: "r2")]
        )
        let result = plan.thisWeeksRecipes(from: [pasta, salad, soup])

        #expect(result.count == 2)
        #expect(result.contains(where: { $0.id == "r1" }))
        #expect(result.contains(where: { $0.id == "r2" }))
    }

    @Test("thisWeeksRecipes() excludes leftovers and takeout meals")
    func excludesNonRecipeMeals() {
        let pasta = makeRecipe(id: "r1", name: "Pasta")
        let plan = WeeklyPlan(
            weekOf: .now,
            meals: [
                .monday: .recipe(id: "r1"),
                .tuesday: .leftovers,
                .wednesday: .takeout
            ]
        )
        let result = plan.thisWeeksRecipes(from: [pasta])
        #expect(result.count == 1)
    }

    @Test("thisWeeksRecipes() returns empty array when no recipe meals are planned")
    func emptyWhenNoRecipes() {
        let pasta = makeRecipe(id: "r1", name: "Pasta")
        let plan = WeeklyPlan(
            weekOf: .now,
            meals: [.monday: .leftovers, .tuesday: .takeout]
        )
        #expect(plan.thisWeeksRecipes(from: [pasta]).isEmpty)
    }

    @Test("thisWeeksRecipes() returns empty array when plan has no meals")
    func emptyWhenNoMeals() {
        let pasta = makeRecipe(id: "r1", name: "Pasta")
        let plan = WeeklyPlan(weekOf: .now, meals: [:])
        #expect(plan.thisWeeksRecipes(from: [pasta]).isEmpty)
    }
}

// MARK: - HouseholdError

@Suite("HouseholdError")
struct HouseholdErrorTests {

    @Test("notAuthenticated has a non-empty error description")
    func notAuthenticatedDescription() {
        let error = HouseholdError.notAuthenticated
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("invalidOrExpiredCode has a non-empty error description")
    func invalidCodeDescription() {
        let error = HouseholdError.invalidOrExpiredCode
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("error descriptions are distinct")
    func descriptionsAreDistinct() {
        #expect(
            HouseholdError.notAuthenticated.errorDescription !=
            HouseholdError.invalidOrExpiredCode.errorDescription
        )
    }
}
