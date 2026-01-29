//
//  GroceryMealPlannerAppUITests.swift
//  GroceryMealPlannerAppUITests
//
//  Created by Andy M on 1/22/26.
//

import XCTest

final class GroceryMealPlannerUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
        
    func testGroceryListAccessibility() throws {
        let groceryNavBar = app.navigationBars["Grocery List"]
        XCTAssertTrue(groceryNavBar.exists)
        
        let addButton = groceryNavBar.buttons["Add Grocery Item"]
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(addButton.isHittable)
        
        let emptyView = app.staticTexts["No groceries yet. Tap + to add items."]
        XCTAssertTrue(emptyView.exists)

    }
    
    func testAddGroceryItemFlow() throws {
        let addButton = app.navigationBars["Grocery List"].buttons["Add Grocery Item"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        let nameField = app.textFields["Item name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Milk")
        
        let quantityField = app.textFields["Quantity"]
        XCTAssertTrue(quantityField.exists)
        quantityField.tap()
        quantityField.typeText("1 Liter")
        
        let addItemButton = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addItemButton.exists)
        XCTAssertTrue(addItemButton.isEnabled)
        addItemButton.tap()
        
        let newItem = app.buttons["Milk"]
        XCTAssertTrue(newItem.waitForExistence(timeout: 2))
        XCTAssertEqual(newItem.value as? String, "Unchecked")

        // Tapping new item checks it off
        newItem.tap()
        XCTAssertEqual(newItem.value as? String, "Checked")
        
        // Clears new item
        let clearCheckedButton = app.navigationBars["Grocery List"].buttons["Clear Checked"]
        XCTAssertTrue(clearCheckedButton.exists)
        clearCheckedButton.tap()
        
        XCTAssertFalse(newItem.waitForExistence(timeout: 2))
    }
    
}
