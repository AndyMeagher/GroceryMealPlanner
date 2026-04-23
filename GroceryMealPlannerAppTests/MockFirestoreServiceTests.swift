import Testing
@testable import GroceryMealPlannerApp

// MARK: - Grocery Items

@Suite("MockFirestoreService — Grocery Items")
struct MockGroceryTests {

    @Test("addGroceryItem stores the item")
    func addStoresItem() async throws {
        let service = MockFirestoreService()
        let item = GroceryItem(name: "Milk", quantity: "1 gallon")
        try await service.addGroceryItem(item)
        #expect(service.groceryItems.count == 1)
        #expect(service.groceryItems.first?.name == "Milk")
    }

    @Test("addGroceryItem preserves quantity")
    func addPreservesQuantity() async throws {
        let service = MockFirestoreService()
        let item = GroceryItem(name: "Eggs", quantity: "12")
        try await service.addGroceryItem(item)
        #expect(service.groceryItems.first?.quantity == "12")
    }

    @Test("deleteGroceryItem removes the item by id")
    func deleteRemovesById() async throws {
        let service = MockFirestoreService()
        var item = GroceryItem(name: "Bread", quantity: nil)
        item.id = "item-1"
        service.groceryItems = [item]
        try await service.deleteGroceryItem(item)
        #expect(service.groceryItems.isEmpty)
    }

    @Test("deleteAllCheckedGroceryItems removes only checked items")
    func deleteCheckedLeavesUnchecked() async throws {
        let service = MockFirestoreService()
        let checked = GroceryItem(name: "Eggs", quantity: nil, isChecked: true)
        let unchecked = GroceryItem(name: "Milk", quantity: "1 gallon", isChecked: false)
        try await service.addGroceryItem(checked)
        try await service.addGroceryItem(unchecked)
        try await service.deleteAllCheckedGroceryItems()
        #expect(service.groceryItems.count == 1)
        #expect(service.groceryItems.first?.name == "Milk")
    }

    @Test("deleteAllCheckedGroceryItems on empty list is a no-op")
    func deleteCheckedOnEmpty() async throws {
        let service = MockFirestoreService()
        try await service.deleteAllCheckedGroceryItems()
        #expect(service.groceryItems.isEmpty)
    }

    @Test("addOrUpdateGroceryItems converts ingredients to grocery items")
    func addIngredientsConvertsToItems() async throws {
        let service = MockFirestoreService()
        let ingredients = [
            Ingredient(name: "Garlic", quantity: "3 cloves"),
            Ingredient(name: "Onion", quantity: "1 large")
        ]
        try await service.addOrUpdateGroceryItems(with: ingredients)
        #expect(service.groceryItems.count == 2)
        let names = service.groceryItems.map(\.name)
        #expect(names.contains("Garlic"))
        #expect(names.contains("Onion"))
    }

    @Test("observeGroceryItems delivers current items synchronously")
    func observeDeliversCurrentItems() {
        let service = MockFirestoreService()
        service.groceryItems = [GroceryItem(name: "Butter", quantity: nil)]
        var received: [GroceryItem] = []
        _ = service.observeGroceryItems(onUpdate: { received = $0 })
        #expect(received.count == 1)
        #expect(received.first?.name == "Butter")
    }
}

// MARK: - Recipes

@Suite("MockFirestoreService — Recipes")
struct MockRecipeTests {

    @Test("addRecipe stores the recipe")
    func addStoresRecipe() async throws {
        let service = MockFirestoreService()
        let recipe = Recipe(name: "Pasta", instructions: "Boil water.")
        try await service.addRecipe(recipe)
        #expect(service.recipes.count == 1)
        #expect(service.recipes.first?.name == "Pasta")
    }

    @Test("addRecipe preserves ingredients")
    func addPreservesIngredients() async throws {
        let service = MockFirestoreService()
        let ingredients = [Ingredient(name: "Spaghetti", quantity: "200g")]
        let recipe = Recipe(name: "Spaghetti Aglio e Olio", instructions: "", ingredients: ingredients)
        try await service.addRecipe(recipe)
        #expect(service.recipes.first?.ingredients.count == 1)
        #expect(service.recipes.first?.ingredients.first?.name == "Spaghetti")
    }

    @Test("deleteRecipe removes the recipe by id")
    func deleteRemovesById() async throws {
        let service = MockFirestoreService()
        var recipe = Recipe(name: "Salad", instructions: "")
        recipe.id = "recipe-1"
        service.recipes = [recipe]
        try await service.deleteRecipe(recipe)
        #expect(service.recipes.isEmpty)
    }

    @Test("observeRecipes delivers current recipes synchronously")
    func observeDeliversCurrentRecipes() {
        let service = MockFirestoreService()
        service.recipes = [Recipe(name: "Soup", instructions: "")]
        var received: [Recipe] = []
        _ = service.observeRecipes(onUpdate: { received = $0 })
        #expect(received.count == 1)
        #expect(received.first?.name == "Soup")
    }
}

// MARK: - Weekly Plans

@Suite("MockFirestoreService — Weekly Plans")
struct MockWeeklyPlanTests {

    @Test("saveWeeklyPlan stores the plan")
    func savePlanStoresPlan() async throws {
        let service = MockFirestoreService()
        let plan = WeeklyPlan(weekOf: .now, meals: [.monday: .leftovers])
        try await service.saveWeeklyPlan(plan)
        #expect(service.weeklyPlans.count == 1)
    }

    @Test("saveWeeklyPlan preserves meals")
    func savePlanPreservesMeals() async throws {
        let service = MockFirestoreService()
        let plan = WeeklyPlan(
            weekOf: .now,
            meals: [.monday: .recipe(id: "r1"), .friday: .takeout]
        )
        try await service.saveWeeklyPlan(plan)
        let saved = service.weeklyPlans.first
        #expect(saved?.meals[.monday] == .recipe(id: "r1"))
        #expect(saved?.meals[.friday] == .takeout)
    }

    @Test("observeWeeklyPlan delivers current plans synchronously")
    func observeDeliversCurrentPlans() {
        let service = MockFirestoreService()
        service.weeklyPlans = [WeeklyPlan(weekOf: .now)]
        var received: [WeeklyPlan] = []
        _ = service.observeWeeklyPlan(onUpdate: { received = $0 })
        #expect(received.count == 1)
    }
}
