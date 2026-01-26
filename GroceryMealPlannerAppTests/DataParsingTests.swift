import XCTest
@testable import GroceryMealPlannerApp
import FirebaseFirestore

struct MockDocumentSnapshot: DocumentSnapshotProtocol {
    let documentID: String
    private let mockData: [String: Any]?
    
    func data() -> [String: Any]? {
        return mockData
    }
    
    init(id: String, data: [String: Any]?) {
        self.documentID = id
        self.mockData = data
    }
}

class FirebaseParserTests: XCTestCase {
    
    // MARK: - Recipe Parsing Tests
    
    func test_parseRecipe_withValidData_returnsRecipe() {
        let mockDoc = MockDocumentSnapshot(
            id: "pasta_carbonara",
            data: [
                "name": "Pasta Carbonara",
                "instructions": "1. Boil pasta\n2. Cook bacon\n3. Mix with eggs",
                "ingredients": [
                    ["id": "1", "name": "Pasta", "quantity": "1 lb"],
                    ["id": "2", "name": "Bacon", "quantity": "6 slices"],
                    ["id": "3", "name": "Eggs", "quantity": "3 large"]
                ],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNotNil(recipe, "Recipe should not be nil")
        XCTAssertEqual(recipe?.id, "pasta_carbonara")
        XCTAssertEqual(recipe?.name, "Pasta Carbonara")
        XCTAssertEqual(recipe?.instructions, "1. Boil pasta\n2. Cook bacon\n3. Mix with eggs")
        XCTAssertEqual(recipe?.ingredients.count, 3)
    }
    
    func test_parseRecipe_withMissingName_returnsNil() {
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_recipe",
            data: [
                "instructions": "Cook something",
                "ingredients": [],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNil(recipe, "Recipe should be nil when name is missing")
    }
    
    func test_parseRecipe_withMissingInstructions_returnsNil() {
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_recipe",
            data: [
                "name": "Test Recipe",
                "ingredients": [],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNil(recipe, "Recipe should be nil when instructions are missing")
    }
    
    func test_parseRecipe_withMissingIngredients_returnsNil() {
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_recipe",
            data: [
                "name": "Test Recipe",
                "instructions": "Cook it",
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNil(recipe, "Recipe should be nil when ingredients are missing")
    }
    
    func test_parseRecipe_withEmptyIngredients_returnsRecipeWithNoIngredients() {
        let mockDoc = MockDocumentSnapshot(
            id: "simple_recipe",
            data: [
                "name": "Simple Recipe",
                "instructions": "Just do it",
                "ingredients": [],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNotNil(recipe)
        XCTAssertEqual(recipe?.ingredients.count, 0)
    }
    
    func test_parseRecipe_withInvalidIngredient_filtersOutInvalidIngredient() {
        let mockDoc = MockDocumentSnapshot(
            id: "recipe_1",
            data: [
                "name": "Test Recipe",
                "instructions": "Test",
                "ingredients": [
                    ["id": "1", "name": "Valid Ingredient", "quantity": "1 cup"],
                    ["id": "2", "name": "Missing Quantity"], // Missing quantity
                    ["name": "No ID", "quantity": "2 cups"], // Missing id
                    ["id": "3", "quantity": "3 tbsp"] // Missing name
                ],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNotNil(recipe)
        XCTAssertEqual(recipe?.ingredients.count, 1, "Should only include valid ingredient")
        XCTAssertEqual(recipe?.ingredients.first?.name, "Valid Ingredient")
    }
    
    func test_parseRecipe_withWrongDataTypes_returnsNil() {
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_types",
            data: [
                "name": 123,
                "instructions": "Test",
                "ingredients": [],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        
        XCTAssertNil(recipe, "Recipe should be nil when data types are wrong")
    }
    
    // MARK: - Weekly Plan Parsing Tests
    
    func test_parseWeeklyPlan_withValidData_returnsWeeklyPlan() {
        
        let weekDate = Date()
        let mockDoc = MockDocumentSnapshot(
            id: "week_2025_01_26",
            data: [
                "weekOf": Timestamp(date: weekDate),
                "meals": [
                    "Monday": "recipe_pasta",
                    "Tuesday": "leftovers",
                    "Wednesday": "recipe_tacos"
                ],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)

        XCTAssertNotNil(plan)
        XCTAssertEqual(plan?.id, "week_2025_01_26")
        XCTAssertEqual(plan?.meals.count, 3)
    }
    
    func test_parseWeeklyPlan_withLeftovers_parsesAsLeftovers() {
        let mockDoc = MockDocumentSnapshot(
            id: "week_1",
            data: [
                "weekOf": Timestamp(date: Date()),
                "meals": ["Monday": "leftovers"],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        
        XCTAssertEqual(plan?.meals[.monday], .leftovers)
    }
    
    func test_parseWeeklyPlan_withTakeout_parsesAsTakeout() {
        let mockDoc = MockDocumentSnapshot(
            id: "week_1",
            data: [
                "weekOf": Timestamp(date: Date()),
                "meals": ["Friday": "takeout"],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        
        XCTAssertEqual(plan?.meals[.friday], .takeout)
    }
    
    func test_parseWeeklyPlan_withRecipeId_parsesAsRecipe() {
        let mockDoc = MockDocumentSnapshot(
            id: "week_1",
            data: [
                "weekOf": Timestamp(date: Date()),
                "meals": ["Thursday": "recipe_chicken_tikka"],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        
        XCTAssertEqual(plan?.meals[.thursday], .recipe(id: "recipe_chicken_tikka"))
    }
    
    func test_parseWeeklyPlan_withMixedMealTypes_parsesAllCorrectly() {
        let mockDoc = MockDocumentSnapshot(
            id: "week_1",
            data: [
                "weekOf": Timestamp(date: Date()),
                "meals": [
                    "Monday": "recipe_pasta",
                    "Tuesday": "leftovers",
                    "Wednesday": "takeout",
                    "Thursday": "recipe_stir_fry",
                    "Friday": "leftovers",
                    "Saturday": "takeout",
                    "Sunday": "recipe_roast"
                ],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        
        XCTAssertNotNil(plan)
        XCTAssertEqual(plan?.meals[.monday], .recipe(id: "recipe_pasta"))
        XCTAssertEqual(plan?.meals[.tuesday], .leftovers)
        XCTAssertEqual(plan?.meals[.wednesday], .takeout)
        XCTAssertEqual(plan?.meals[.thursday], .recipe(id: "recipe_stir_fry"))
        XCTAssertEqual(plan?.meals[.friday], .leftovers)
        XCTAssertEqual(plan?.meals[.saturday], .takeout)
        XCTAssertEqual(plan?.meals[.sunday], .recipe(id: "recipe_roast"))
    }
    
    func test_parseWeeklyPlan_withInvalidDayOfWeek_ignoresInvalidDay() {
        let mockDoc = MockDocumentSnapshot(
            id: "week_1",
            data: [
                "weekOf": Timestamp(date: Date()),
                "meals": [
                    "Monday": "recipe_pasta",
                    "funday": "recipe_pizza" // Invalid day
                ],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        
        XCTAssertNotNil(plan)
        XCTAssertEqual(plan?.meals.count, 1, "Should only include valid day")
        XCTAssertEqual(plan?.meals[.monday], .recipe(id: "recipe_pasta"))
    }
    
    func test_parseWeeklyPlan_withMissingWeekOf_returnsNil() {
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_plan",
            data: [
                "meals": ["Monday": "recipe_pasta"],
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        
        XCTAssertNil(plan, "Plan should be nil when weekOf is missing")
    }
    
    // MARK: - Grocery Item Parsing Tests
    
    func test_parseGroceryItem_withValidData_returnsGroceryItem() {
        let mockDoc = MockDocumentSnapshot(
            id: "milk",
            data: [
                "name": "Whole Milk",
                "quantity": "1 gallon",
                "isChecked": false,
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.id, "milk")
        XCTAssertEqual(item?.name, "Whole Milk")
        XCTAssertEqual(item?.quantity, "1 gallon")
        XCTAssertFalse(item?.isChecked ?? true)
    }
    
    func test_parseGroceryItem_withoutQuantity_returnsGroceryItemWithNilQuantity() {
        let mockDoc = MockDocumentSnapshot(
            id: "bread",
            data: [
                "name": "Bread",
                "isChecked": true,
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.name, "Bread")
        XCTAssertNil(item?.quantity, "Quantity should be nil when not provided")
        XCTAssertTrue(item?.isChecked ?? false)
    }
    
    func test_parseGroceryItem_withCheckedTrue_returnsCheckedItem() {
        let mockDoc = MockDocumentSnapshot(
            id: "eggs",
            data: [
                "name": "Eggs",
                "quantity": "1 dozen",
                "isChecked": true,
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
       
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)

        XCTAssertTrue(item?.isChecked ?? false)
    }
    
    func test_parseGroceryItem_withCheckedFalse_returnsUncheckedItem() {
        
        let mockDoc = MockDocumentSnapshot(
            id: "butter",
            data: [
                "name": "Butter",
                "isChecked": false,
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
    
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
       
        XCTAssertFalse(item?.isChecked ?? true)
    }
    
    func test_parseGroceryItem_withMissingName_returnsNil() {
        
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_item",
            data: [
                "quantity": "5 lbs",
                "isChecked": false,
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
    
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
       
        XCTAssertNil(item, "Item should be nil when name is missing")
    }
    
    func test_parseGroceryItem_withMissingIsChecked_returnsNil() {
        
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_item",
            data: [
                "name": "Test Item",
                "quantity": "1 unit",
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
    
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
       
        XCTAssertNil(item, "Item should be nil when isChecked is missing")
    }
    
    func test_parseGroceryItem_withMissingTimestamps_returnsNil() {
        
        let mockDoc = MockDocumentSnapshot(
            id: "invalid_item",
            data: [
                "name": "Test Item",
                "isChecked": false
            ]
        )
        
    
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
       
        XCTAssertNil(item, "Item should be nil when timestamps are missing")
    }
    
    func test_parseGroceryItem_withEmptyString_returnsItemWithEmptyName() {
        
        let mockDoc = MockDocumentSnapshot(
            id: "empty_name",
            data: [
                "name": "",
                "isChecked": false,
                "createdAt": Date(),
                "updatedAt": Date()
            ]
        )
        
    
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
       
        XCTAssertNotNil(item, "Parser doesn't validate empty strings, just presence")
        XCTAssertEqual(item?.name, "")
    }
    
    // MARK: - Edge Cases
    
    func test_allParsers_withNilData_returnNil() {
        
        let mockDoc = MockDocumentSnapshot(id: "nil_data", data: nil)
        
    
        let recipe = FirebaseParser.parseRecipe(from: mockDoc)
        let plan = FirebaseParser.parseWeeklyPlan(from: mockDoc)
        let item = FirebaseParser.parseGroceryItem(from: mockDoc)
        
       
        XCTAssertNil(recipe)
        XCTAssertNil(plan)
        XCTAssertNil(item)
    }
}
