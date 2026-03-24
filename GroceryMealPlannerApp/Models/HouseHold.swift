//
//  HouseHold.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 3/23/26.
//

import Foundation
import FirebaseFirestore

struct Household: Identifiable, Codable {
    @DocumentID var id: String?
    var ownerId: String
    var members: [String] // member UIDs
    var createdAt: Date
    var updatedAt: Date
}

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var displayName: String
}

struct HouseholdInvite: Codable {
    let householdId: String
    let createdBy: String
    let expiresAt: Date
}

enum HouseholdError: LocalizedError {
    case notAuthenticated
    case invalidOrExpiredCode
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: "You must be signed in to join a household."
        case .invalidOrExpiredCode: "Invalid or expired invite code."
        }
    }
}
