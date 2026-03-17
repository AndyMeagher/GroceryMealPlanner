//
//  GroceryCategorizer.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 2/6/26.
//

import Foundation

struct GroceryCategorizer {

    private static let functionURL = "https://us-central1-grocerymealplanner.cloudfunctions.net/getItemCategory"

    static func category(for phrase: String) async -> GroceryCategory {
        guard let url = URL(string: "\(functionURL)?name=\(phrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? phrase)") else {
            return .unknown
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode(AisleResponse.self, from: data)
            return GroceryCategory(rawValue: json.aisle) ?? .unknown
        } catch {
            print("GroceryCategorizer error:", error)
            return .unknown
        }
    }
}

private struct AisleResponse: Decodable {
    let aisle: String
}
