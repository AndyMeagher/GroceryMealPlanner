//
//  GroceryCategorizer.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 2/6/26.
//

import CoreML
import NaturalLanguage

class GroceryCategorizer {

    private let nlModel: NLModel?

    init() {
        do {
            let coreML = try GroceryTextClassifier(configuration: .init())
            nlModel = try NLModel(mlModel: coreML.model)
        } catch {
            nlModel = nil
            print("Model load failed:", error)
        }
    }

    func category(for phrase: String, threshold: Double = 0.6) -> String {
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
