//
//  FirebaseService.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 1/29/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

struct ImportedRecipe: Decodable {
    let name: String
    let instructions: String
    let ingredients: [Ingredient]
}

protocol FirestoreServiceProtocol {
    
    func setupHousehold() async throws
    func saveUserProfile(displayName: String) async throws
    func observeHousehold(
        onUpdate: @escaping (Household) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    func fetchHouseholdMembers(memberIds: [String]) async throws -> [UserProfile]
    
    func generateInviteCode() async throws -> String
    func joinHousehold(code: String) async throws
    
    func observeGroceryItems(
        onUpdate: @escaping ([GroceryItem]) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    
    func addGroceryItem(_ item: GroceryItem) async throws
    func updateGroceryItem(_ item: GroceryItem) async throws
    func deleteGroceryItem(_ item: GroceryItem) async throws
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async throws
    func deleteAllCheckedGroceryItems() async throws
    
    func observeRecipes(
        onUpdate: @escaping ([Recipe]) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    
    func addRecipe(_ recipe: Recipe) async throws
    func updateRecipe(_ recipe: Recipe) async throws
    func deleteRecipe(_ recipe: Recipe) async throws
    
    func importRecipeFromUrl(_ url: URL) async throws -> ImportedRecipe?
    
    func observeWeeklyPlan(
        onUpdate: @escaping ([WeeklyPlan]) -> Void,
        onError: ((String) -> Void)?
    ) -> ListenerRegistration?
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) async throws
}

class FirestoreService : FirestoreServiceProtocol {
    
    private var dataBase: Firestore { Firestore.firestore() }
    private var householdId: String = ""
    
    // MARK: Authentication
    
    func setupHousehold() async throws {
        _ = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
        householdId = try await getOrCreateHouseholdId()
    }
    
    private func getOrCreateHouseholdId() async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw HouseholdError.notAuthenticated
        }
        
        let userDoc = try await dataBase.collection("users").document(uid).getDocument()
        if let id = userDoc.data()?["householdId"] as? String {
            return id
        }
        
        let newHousehold = Household(ownerId: uid, members: [uid], createdAt: .now, updatedAt: .now)
        let ref = try dataBase.collection("households").addDocument(from: newHousehold)
        
        try await dataBase.collection("users").document(uid)
            .setData(["householdId": ref.documentID], merge: true)
        
        return ref.documentID
    }
    
    func saveUserProfile(displayName: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw HouseholdError.notAuthenticated }
        try await dataBase.collection("users").document(uid).setData(["displayName": displayName], merge: true)
    }
    
    func observeHousehold(
        onUpdate: @escaping (Household) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        return dataBase.document("households/\(householdId)")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading household: \(error.localizedDescription)")
                    return
                }
                guard let snapshot, snapshot.exists else { return }
                do {
                    onUpdate(try snapshot.data(as: Household.self))
                } catch {
                    onError?("Failed to decode household: \(error.localizedDescription)")
                }
            }
    }
    
    func fetchHouseholdMembers(memberIds: [String]) async throws -> [UserProfile] {
        guard !memberIds.isEmpty else { return [] }
        let snapshot = try await dataBase.collection("users")
            .whereField(FieldPath.documentID(), in: memberIds)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: UserProfile.self) }
    }
    
    // MARK: - Path configuration
    
    private var dataBasePath: String {
        "households/\(householdId)"
    }
    
    // MARK: Invite Codes
    
    func generateInviteCode() async throws -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let code = String((0..<7).map { _ in characters.randomElement()! })
        
        let invite = HouseholdInvite(
            householdId: householdId,
            createdBy: Auth.auth().currentUser!.uid,
            expiresAt: .now.addingTimeInterval(72 * 3600)
        )
        
        try dataBase.collection("invites").document(code).setData(from: invite)
        return code
    }
    
    func joinHousehold(code: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw HouseholdError.notAuthenticated
        }
        
        let doc = try await dataBase.collection("invites").document(code).getDocument()
        let invite = try doc.data(as: HouseholdInvite.self)
        
        guard invite.expiresAt > .now else {
            throw HouseholdError.invalidOrExpiredCode
        }
        
        try await dataBase.collection("households").document(invite.householdId)
            .updateData(["members": FieldValue.arrayUnion([uid])])
        // TODO
        // try await dataBase.collection("invites").document(code).delete()
        
        try await dataBase.collection("users").document(uid)
            .setData(["householdId": invite.householdId], merge: true)
        householdId = invite.householdId
    }
    
    
    // MARK: - Grocery Items Methods
    
    func observeGroceryItems(
        onUpdate: @escaping ([GroceryItem]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        return dataBase.collection("\(dataBasePath)/groceries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading groceries: \(error.localizedDescription)")
                    return
                }
                
                let items: [GroceryItem] = snapshot?.documents.compactMap { snapshot in
                    
                    do {
                        return try snapshot.data(as: GroceryItem.self)
                    } catch {
                        onError?("Failed to decode item: \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
                onUpdate(items)
            }
    }
    
    func addGroceryItem(_ item: GroceryItem) throws {
        if let id = item.id{
            try dataBase.collection("\(dataBasePath)/groceries").document(id).setData(from: item, merge: true)
        }else{
            try dataBase.collection("\(dataBasePath)/groceries").addDocument(from: item)
        }
    }
    
    func updateGroceryItem(_ item: GroceryItem) async throws  {
        var updatedItem = item
        updatedItem.updatedAt = Date()
        try addGroceryItem(updatedItem)
    }
    
    func deleteGroceryItem(_ item: GroceryItem) async throws {
        guard let id = item.id else {
            print("No ID for grocery Item")
            return
        }
        try await dataBase.collection("\(dataBasePath)/groceries").document(id).delete()
    }
    
    func addOrUpdateGroceryItems(with ingredients: [Ingredient]) async throws {
        var results: [GroceryItem] = []
        
        let batch = dataBase.batch()
        for item in ingredients {
            let docRef = dataBase.collection("\(dataBasePath)/groceries").document(item.id)
            let groceryItem = GroceryItem(name: item.name, quantity: item.quantity, isChecked: false)
            
            try batch.setData(from: groceryItem, forDocument: docRef, merge: true)
            
            results.append(groceryItem)
        }
        
        try await batch.commit()
    }
    
    func deleteAllCheckedGroceryItems() async throws {
        let snapshot = try await dataBase.collection("\(dataBasePath)/groceries")
            .whereField("isChecked", isEqualTo: true)
            .getDocuments()
        
        guard !snapshot.documents.isEmpty else {
            print("No checked items to delete")
            return
        }
        
        let batch = dataBase.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }
    
    // MARK: - Recipes
    
    func observeRecipes(
        onUpdate: @escaping ([Recipe]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        return dataBase.collection("\(dataBasePath)/recipes")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading recipes: \(error.localizedDescription)")
                    return
                }
                
                let items: [Recipe] = snapshot?.documents.compactMap { snapshot in
                    do {
                        return try snapshot.data(as: Recipe.self)
                    } catch {
                        onError?("Failed to decode item: \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
                onUpdate(items)
            }
    }
    
    func addRecipe(_ recipe: Recipe) throws {
        if let id = recipe.id{
            try dataBase.collection("\(dataBasePath)/recipes").document(id).setData(from: recipe)
        }else{
            try dataBase.collection("\(dataBasePath)/recipes").addDocument(from: recipe)
        }
    }
    
    func updateRecipe(_ recipe: Recipe) throws {
        var updatedRecipe = recipe
        updatedRecipe.updatedAt = Date()
        try addRecipe(updatedRecipe)
    }
    
    func deleteRecipe(_ recipe: Recipe) async throws {
        guard let id = recipe.id else {
            print("No ID for recipe")
            return
        }
        try await dataBase.collection("\(dataBasePath)/recipes").document(id).delete()
    }
    
    func importRecipeFromUrl(_ url: URL) async throws -> ImportedRecipe? {
        let functions = Functions.functions()

        let result = try await functions.httpsCallable("importRecipeFromUrl").call(["url": url.absoluteString])

        guard let data = result.data as? [String: Any],
              let recipeData = data["recipe"] as? [String: Any] else {
            throw NSError(domain: "RecipeImport", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        let jsonData = try JSONSerialization.data(withJSONObject: recipeData)
        return try JSONDecoder().decode(ImportedRecipe.self, from: jsonData)
    }
    
    // MARK: - WeeklyPlan
    
    func observeWeeklyPlan(
        onUpdate: @escaping ([WeeklyPlan]) -> Void,
        onError: ((String) -> Void)? = nil
    ) -> ListenerRegistration? {
        let startOfWeek = Date().startOfWeek()
        
        return dataBase.collection("\(dataBasePath)/weeklyPlans")
            .whereField("weekOf", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError?("Error loading weekly plans: \(error.localizedDescription)")
                    return
                }
                let weeklyPlans: [WeeklyPlan] = snapshot?.documents.compactMap { snapshot in
                    do {
                        return try snapshot.data(as: WeeklyPlan.self)
                    } catch {
                        onError?("Failed to decode item: \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
                
                onUpdate(weeklyPlans)
            }
    }
    
    func saveWeeklyPlan(_ plan: WeeklyPlan) throws {
        if let id = plan.id{
            try dataBase.collection("\(dataBasePath)/weeklyPlans").document(id).setData(from: plan, merge: true)
        }else{
            try dataBase.collection("\(dataBasePath)/weeklyPlans").addDocument(from: plan)
        }
    }
}
