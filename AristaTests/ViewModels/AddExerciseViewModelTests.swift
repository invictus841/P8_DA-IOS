//
//  AddExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 04/03/2025.
//

import Testing
import XCTest
import CoreData
@testable import Arista

class AddExerciseViewModelTests: XCTestCase {

    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)

        for exercise in objects {
            context.delete(exercise)
        }
        let userFetchRequest = User.fetchRequest()
        let userObjects = try! context.fetch(userFetchRequest)
        
        for user in userObjects {
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

    func test_Init_SetsInitialState() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext

        // When
        let viewModel = AddExerciseViewModel(context: context)

        // Then
        XCTAssertEqual(viewModel.category, "", "Category should be initially empty")
        XCTAssertNotNil(viewModel.startTime, "Start time should have a default value") // It's initialized to Date()
        XCTAssertEqual(viewModel.duration, 0, "Duration should be initially 0")
        XCTAssertEqual(viewModel.intensity, 0, "Intensity should be initially 0")
        XCTAssertNil(viewModel.error, "Error should be initially nil")
    }

    func test_AddExercise_SuccessfullyAddsExercise() throws {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        addUser(context: context, firstName: "John", lastName: "Doe") // Add a user
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Running"
        viewModel.duration = 30
        viewModel.intensity = 5
        viewModel.startTime = Date()

        // When
        let result = viewModel.addExercise()

        // Then
        XCTAssertTrue(result, "addExercise should return true")
        XCTAssertNil(viewModel.error, "Error should be nil")

        // Verify that the exercise was actually added to the database
        let fetchRequest = Exercise.fetchRequest()
        let exercises = try context.fetch(fetchRequest)
        XCTAssertEqual(exercises.count, 1, "There should be one exercise in the database")
        let addedExercise = exercises.first!
        XCTAssertEqual(addedExercise.category, "Running", "Category should match")
        XCTAssertEqual(Int(addedExercise.duration), 30, "Duration should match")
        XCTAssertEqual(Int(addedExercise.intensity), 5, "Intensity should match")
    }

    func test_AddExercise_HandlesCoreDataError() {
        // Given
        let persistenceController = PersistenceController(inMemory: true, applyDefaultData: false)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)

        // Force a Core Data error by not adding a User (the UserRepository will throw)
//        addUser(context: context, firstName: "", lastName: "") // Add a user
        
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Swimming"
        viewModel.duration = 45
        viewModel.intensity = 7
        viewModel.startTime = Date()

        // When
        let result = viewModel.addExercise()

        // Then
        XCTAssertFalse(result, "addExercise should return false")
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        
        // Verify the specific error type
        if let error = viewModel.error {
                switch error {
                case .noUserFound:
                    // Expected error: no user found
                    break // Success!
                case .coreDataError(let coreDataError):
                    XCTFail("Unexpected error: Core Data error - \(coreDataError)")
                case .invalidInput(_):
                    XCTFail("invalidInput")
                case .unknown(_):
                    XCTFail("unknown")
                }
            } else {
                XCTFail("Unexpected error type: Error is not an AppError")
            }
    }
}
