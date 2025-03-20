//
//  ModelService+User.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation
import CoreData

extension ModelService {
    // MARK: - User Operations
    
    func createUser(data: UserData) throws {
        let newUser = User(context: viewContext)
        newUser.id = data.id
        newUser.firstName = data.firstName
        newUser.lastName = data.lastName
        
        try viewContext.save()
    }

    func getUser() throws -> UserData? {
        let request = User.fetchRequest()
        request.fetchLimit = 1

        guard let user = try viewContext.fetch(request).first else {
            return nil
        }

        return UserData(id: user.id ?? UUID().uuidString, firstName: user.firstName ?? "", lastName: user.lastName ?? "")
    }
    
    func getUserCoreData() throws -> User? {
        let request = User.fetchRequest()
        request.fetchLimit = 1

        guard let user = try viewContext.fetch(request).first else {
            return nil
        }

        return user
    }
}
