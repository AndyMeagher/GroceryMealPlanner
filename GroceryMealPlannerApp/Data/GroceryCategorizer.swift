//
//  GroceryCategorizer.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 2/6/26.
//

import CoreML
import NaturalLanguage

struct GroceryCategorizer {

    private static let nlModel: NLModel? = {
        do {
            let coreML = try GroceryTextClassifier(configuration: .init())
            return try NLModel(mlModel: coreML.model)
        } catch {
            print("Model load failed:", error)
            return nil
        }
    }()

    static func category(for phrase: String, threshold: Double = 0.5) -> String {
        guard let nlModel else {
            return "Other"
        }

        let hypotheses = nlModel.predictedLabelHypotheses(
            for: phrase.lowercased(),
            maximumCount: 1
        )

        guard let (label, confidence) = hypotheses.first else {
            return "Other"
        }
        return confidence >= threshold ? label : "Other"
    }
}
