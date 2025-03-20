//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import XCTest
import CoreData
@testable import Arista

class ModelServiceUserTests: XCTestCase {

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
        newUser.id = UUID().uuidString

        try! context.save()
    }

    func test_WhenNoUsersInDatabase_GetUser_ReturnNil() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let modelService = ModelService(context: context)

        // When
        let userData = try! modelService.getUser()

        // Then
        XCTAssertNil(userData, "User data should be nil")
    }

    func test_WhenOneUserInDatabase_GetUser_ReturnTheUserData() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let firstName = "John"
        let lastName = "Doe"
        addUser(context: context, firstName: firstName, lastName: lastName)
        let modelService = ModelService(context: context)

        // When
        let userData = try! modelService.getUser()

        // Then
        XCTAssertNotNil(userData, "User data should not be nil")
        XCTAssertEqual(userData?.firstName, firstName, "First name should match")
        XCTAssertEqual(userData?.lastName, lastName, "Last name should match")
    }
    
    func test_WhenNoUsersInDatabase_GetUserCoreData_ReturnNil() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let modelService = ModelService(context: context)

        // When
        let user = try! modelService.getUserCoreData()

        // Then
        XCTAssertNil(user, "User should be nil")
    }
    
    func test_WhenOneUserInDatabase_GetUserCoreData_ReturnTheUser() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let firstName = "John"
        let lastName = "Doe"
        addUser(context: context, firstName: firstName, lastName: lastName)
        let modelService = ModelService(context: context)

        // When
        let user = try! modelService.getUserCoreData()

        // Then
        XCTAssertNotNil(user, "User should not be nil")
        XCTAssertEqual(user?.firstName, firstName, "First name should match")
        XCTAssertEqual(user?.lastName, lastName, "Last name should match")
    }
    
    func test_CreateUser_ShouldSaveUserToDB() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let firstName = "Jane"
        let lastName = "Smith"
        let userData = UserData(id: UUID().uuidString, firstName: firstName, lastName: lastName)
        let modelService = ModelService(context: context)
        
        // When
        try! modelService.createUser(data: userData)
        
        // Then
        let fetchRequest = User.fetchRequest()
        let users = try! context.fetch(fetchRequest)
        XCTAssertEqual(users.count, 1, "There should be 1 user in the database")
        XCTAssertEqual(users.first?.firstName, firstName, "First name should match")
        XCTAssertEqual(users.first?.lastName, lastName, "Last name should match")
    }
}
