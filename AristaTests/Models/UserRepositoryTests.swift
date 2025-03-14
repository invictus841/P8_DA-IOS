//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import XCTest
import CoreData
@testable import Arista

struct UserRepositoryTests {

    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = User.fetchRequest()
        let objects = try! context.fetch(fetchRequest)

        for user in objects {
            context.delete(user)
        }

        try! context.save()
    }

    private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String) {
        let newUser = User(context: context)
        newUser.firstName = firstName
        newUser.lastName = lastName

        try! context.save()
    }

    func test_WhenNoUsersInDatabase_GetUser_ReturnNil() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let repository = UserRepository(viewContext: context)

        // When
        let user = try! repository.getUser()

        // Then
        XCTAssertNil(user, "User should be nil")
    }

    func test_WhenOneUserInDatabase_GetUser_ReturnTheUser() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let firstName = "John"
        let lastName = "Doe"
        addUser(context: context, firstName: firstName, lastName: lastName)
        let repository = UserRepository(viewContext: context)

        // When
        let user = try! repository.getUser()

        // Then
        XCTAssertNotNil(user, "User should not be nil")
        XCTAssertEqual(user.firstName, firstName, "First name should match")
        XCTAssertEqual(user.lastName, lastName, "Last name should match")
    }
}
