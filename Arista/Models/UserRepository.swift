//
//  UserRepository.swift
//  Arista
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import Foundation
import CoreData

struct UserRepository {
    let viewContext: NSManagedObjectContext
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    // User n'est plus optionel, et on handle l'error
    func getUser() throws -> User {
            let request = User.fetchRequest()
            request.fetchLimit = 1
            if let user = try viewContext.fetch(request).first {
                return user
            } else {
                throw AppError.noUserFound
            }
        }
}
