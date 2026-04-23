# This Week's Eats iOS App

A personal SwiftUI iOS app for meal planning and grocery tracking, built for shared household use. Plan meals for the week, generate grocery lists, and keep everything in sync across your household in real time.

---

## Requirements

- **Xcode:** 26.2 or higher  
- **Swift:** 6.0+  
- **iOS:** 17.6+
  
---

## Running the App

1. Open the project in Xcode
2. Build and run on a simulator or device

_Note: Requires a `GoogleServices-Info.plist` file for Firebase configuration._

---

## What the App Does

- Sign in with **Apple Login**
- Invite household members to share grocery lists and meal plans
- Create and manage recipes, or import them directly from a URL via the **Spoonacular API**
- Plan meals by day of the week
- Generate a grocery list manually or from your assigned weekly recipes
- Grocery items are automatically **categorized** using the Spoonacular API
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
- **Firebase Firestore** for real-time data sync across household members
- **Firebase Functions** backend for server-side logic including Spoonacular API integration
- **Sign in with Apple** for secure, privacy-friendly authentication
- **Household invite system** allowing multiple users to share a single household's lists and plans
- **Spoonacular API** for recipe extraction from URLs and automatic grocery item categorization
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
│   ├── KeychainHelper.swift
│   └── DateTimeHelpers.swift
├── Styles/                 # Design system
│   └── FontSystem.swift
└── Fonts/                  # Custom typography assets
└── GlobalAlertToast        # Centralized observer of error messages with UI toast
```

---

## Backend: Firebase Functions

Server-side logic runs on **Firebase Functions**, including:

- Calling the Spoonacular API to extract recipes from URLs
- Categorizing grocery ingredients returned by Spoonacular
- Household invite validation and management

---

## Testing & Mocking

Protocols abstract Firebase calls, enabling both unit and UI tests without hitting live services.

---

## Future Considerations

- **Enhanced Error Handling** – More robust feedback for network issues, permission errors, and data validation failures.
- **Pagination & Performance** – Lazy loading and pagination for large datasets.
- **Richer Recipe UI** – Improved recipe creation with images and better organization.
- **Expanded Testing** – More comprehensive unit and UI test coverage across all core flows.
