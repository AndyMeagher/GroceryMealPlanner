# This Week's Eats iOS App

A personal SwiftUI iOS app for meal planning and grocery tracking.  
Originally built for my partner and I to manage meal planning and grocery shopping for the week as a shared household, this version has been adapted for demo and interview purposes.

---

## Requirements

- **Xcode:** 26.2 or higher  
- **Swift:** 6.0+  
- **iOS:** 17.6+
  
---

## Running the App
	1.	Open the project in Xcode
	2.	Build and run on a simulator or device

_Note: Firebase should be preconfigured for demo purposes; no additional setup is required_

---

## What the App Does

- Create and manage recipes
- Plan meals by day of the week
- Generate Grocery list manually or using assigned recipes
- Support accessibility features like VoiceOver and Dynamic Type
  
<div style="display: flex; gap: 100px; align-items: center;">
<img width="250"  alt="Grocery" src="https://github.com/user-attachments/assets/de93cc86-8372-4f63-b87a-70147149659c" />
  &nbsp;&nbsp;
<img width="250"  alt="RecipeCard" src="https://github.com/user-attachments/assets/44ca60d0-262e-44b6-90ff-5155a709e645" />
  &nbsp;&nbsp;
<img width="250"  alt="ThisWeek" src="https://github.com/user-attachments/assets/24c4ac5a-fa7c-47e5-ae3c-ef7107be0e79" />
</div>

---

## Technical Highlights

- **SwiftUI + Swift Concurrency (async/await)**
- **Centralized data store (`AppDataStore`) as a single source of truth**
- **Firebase Firestore** for real-time data sync
- **Protocol-based abstraction** with a mock implementation for testing
- **Custom font system** and reusable UI components

---

## Project Structure

```
├── Models/                  # Data models matching Firestore schema
│   ├── Recipe.swift
│   ├── GroceryItem.swift
│   └── WeeklyPlan.swift
├── Data/
│   ├── Firebase/           # Firebase service layer
│   │   ├── FirebaseService.swift
│   │   ├── MockFirebaseService.swift
│   │   └── FirebaseModelMapper.swift
│   └── Store/              # Data management layer
│       └── AppDataStore.swift
├── Views/                  # SwiftUI views organized by feature
│   ├── Groceries/
│   ├── Recipes/
│   ├── WeeklyPlan/
│   └── MainTabs.swift
├── Utils/                  # Helper utilities
│   ├── KeychainHelper.swift // Small Helper to allow my partner and I a shared household endpoint
│   └── DateTimeHelpers.swift
├── Styles/                 # Design system
│   └── FontSystem.swift
└── Fonts/                  # Custom typography assets
└──GlobalAlertToast     # Centeralized Observer of Error Messages with UI Toast
```
---

## Testing & Mocking

- Protocols were created to abstract Firebase calls from both Unit and UI tests. 

---

## Why This Project

This app reflects how I approach real production code:
- Start simple
- Solve a real problem
- Evolve architecture only when needed
- Keep state predictable and testable
- Prioritize accessibility and maintainability

## Future Considerations

This app was built in about a week, so many features and scalability improvements were limited by time. Given more time, I would focus on:
	
- **Full Authentication Layer** – Implement a proper login system to fully support shared household endpoints across multiple users. 

- **Grocery Categorization** – Automatically classify items (Produce, Meat, Dairy, etc.) for better organization and easier shopping[^1].
[^1]: Currently in-progress under the branch andy/grocery-categories. 

- **Enhanced Error Handling** – Provide more robust feedback for network issues, permission errors, and data validation failures.

- **Pagination & Performance** – Add lazy loading and pagination to efficiently handle large datasets.

- **Richer Recipe UI** – Improve the recipe creation experience with images, easier importing, and better organization.

- **Expanded Testing** – While a testing layer exists, I would add more comprehensive unit and UI tests to cover all core flows.
