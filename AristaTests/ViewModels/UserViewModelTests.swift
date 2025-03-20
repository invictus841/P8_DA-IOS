//
//  UserViewModelTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 20/03/2025.
//

import XCTest
import CoreData
@testable import Arista

class UserDataViewModelTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let userFetchRequest = User.fetchRequest()
        let userObjects = try! context.fetch(userFetchRequest)
        
        for user in userObjects {
            context.delete(user)
        }
        
        try! context.save()
    }
    
    private func createUser(context: NSManagedObjectContext, firstName: String, lastName: String) -> User {
        let user = User(context: context)
        user.firstName = firstName
        user.lastName = lastName
        user.id = UUID().uuidString
        
        try! context.save()
        return user
    }
    
    func test_Init_WithExistingUser_LoadsUserData() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let testFirstName = "John"
        let testLastName = "Doe"
        let _ = createUser(context: context, firstName: testFirstName, lastName: testLastName)
        
        let modelService = ModelService(context: context)
        
        // When
        let viewModel = UserDataViewModel(modelService: modelService)
        
        // Then
        XCTAssertEqual(viewModel.firstName, testFirstName, "First name should be loaded")
        XCTAssertEqual(viewModel.lastName, testLastName, "Last name should be loaded")
        XCTAssertNil(viewModel.error, "Error should be nil")
    }
    
    func test_Init_WithNoUser_SetsEmptyStringsAndError() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let modelService = ModelService(context: context)
        
        // When
        let viewModel = UserDataViewModel(modelService: modelService)
        
        // Then
        XCTAssertEqual(viewModel.firstName, "", "First name should be empty")
        XCTAssertEqual(viewModel.lastName, "", "Last name should be empty")
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        
        if let error = viewModel.error as? AppError {
            XCTAssertTrue(error == .noUserFound, "Error should be noUserFound")
        } else {
            XCTFail("Error should be AppError.noUserFound")
        }
    }
    
    func test_Init_WhenGetUserThrowsError_SetsError() {
        // Given
        // Create a mock ModelService that throws an error when getUser is called
        class MockModelService: ModelServiceProtocol {
            func getUser() throws -> UserData? {
                throw AppError.coreDataError(NSError(domain: "test", code: 123, userInfo: nil))
            }
            
            // Implement other required methods (they won't be called in this test)
            func getUserCoreData() throws -> User? { return nil }
            func createUser(data: UserData) throws {}
            func getSleepSessions() throws -> [SleepData] { return [] }
            func addSleep(data: SleepData) throws {}
            func deleteSleep(sleep data: SleepData) throws {}
            func getExercises() throws -> [ExerciseData] { return [] }
            func addExercise(data: ExerciseData) throws {}
            func deleteExercise(exercise data: ExerciseData) throws {}
        }
        
        let mockModelService = MockModelService()
        
        // When
        let viewModel = UserDataViewModel(modelService: mockModelService)
        
        // Then
        XCTAssertEqual(viewModel.firstName, "", "First name should be empty")
        XCTAssertEqual(viewModel.lastName, "", "Last name should be empty")
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        
        if let error = viewModel.error as? AppError {
            switch error {
            case .coreDataError(_):
                // Expected error type
                break
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } else {
            XCTFail("Error should be an AppError")
        }
    }
}
