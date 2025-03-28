//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import XCTest
import CoreData
@testable import Arista

class SleepViewModelTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        // Clear sleep entities
        let sleepFetchRequest = Sleep.fetchRequest()
        let sleepObjects = try! context.fetch(sleepFetchRequest)
        
        for sleep in sleepObjects {
            context.delete(sleep)
        }
        
        // Clear user entities
        let userFetchRequest = User.fetchRequest()
        let userObjects = try! context.fetch(userFetchRequest)
        
        for user in userObjects {
            context.delete(user)
        }

        try! context.save()
    }
    
    private func createUser(context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.firstName = "Test"
        user.lastName = "User"
        user.id = UUID().uuidString
        
        try! context.save()
        return user
    }
    
    private func addSleepToDatabase(context: NSManagedObjectContext, user: User, duration: Int, quality: Int, startDate: Date) -> Sleep {
        let sleep = Sleep(context: context)
        sleep.id = UUID().uuidString
        sleep.duration = Int64(duration)
        sleep.quality = Int64(quality)
        sleep.startDate = startDate
        sleep.user = user
        
        try! context.save()
        return sleep
    }
    
    func test_FetchSleepSessions_LoadsSessionsFromDatabase() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let user = createUser(context: context)
        let modelService = ModelService(context: context)
        
        // Add some sleep sessions to the database
        let sleep1 = addSleepToDatabase(
            context: context,
            user: user,
            duration: 480, // 8 hours
            quality: 8,
            startDate: Date()
        )
        
        let sleep2 = addSleepToDatabase(
            context: context,
            user: user,
            duration: 420, // 7 hours
            quality: 6,
            startDate: Date(timeIntervalSinceNow: -86400) // Yesterday
        )
        
        // Create the view model - this will automatically call fetchSleepSessions() in init
        let viewModel = SleepViewModel(modelService: modelService)
        
        // Initial state should have the sessions we added
        XCTAssertEqual(viewModel.sleepSessions.count, 2, "Should have loaded two sleep sessions during initialization")
        
        // When - clear the array and reload to test the fetchSleepSessions method explicitly
        viewModel.sleepSessions = []
        XCTAssertEqual(viewModel.sleepSessions.count, 0, "Sleep sessions should be empty after manual clearing")
        
        viewModel.fetchSleepSessions()
        
        // Then
        XCTAssertEqual(viewModel.sleepSessions.count, 2, "Should load two sleep sessions")
        
        // Verify first session (most recent should be first due to sorting)
        let firstSession = viewModel.sleepSessions[0]
        XCTAssertEqual(Int64(firstSession.duration), sleep1.duration, "Duration should match")
        XCTAssertEqual(Int64(firstSession.quality), sleep1.quality, "Quality should match")
        
        // Verify second session
        let secondSession = viewModel.sleepSessions[1]
        XCTAssertEqual(Int64(secondSession.duration), sleep2.duration, "Duration should match")
        XCTAssertEqual(Int64(secondSession.quality), sleep2.quality, "Quality should match")
        
        XCTAssertNil(viewModel.error, "Error should be nil")
    }
    
    func test_FetchSleepSessions_HandlesErrors() {
        // Given
        // Create a mock ModelService that throws an error when getSleepSessions is called
        class MockModelService: ModelServiceProtocol {
            func getSleepSessions() throws -> [SleepData] {
                throw AppError.coreDataError(NSError(domain: "test", code: 123, userInfo: nil))
            }
            
            // Implement other required methods (they won't be called in this test)
            func getUser() throws -> UserData? { return nil }
            func getUserCoreData() throws -> User? { return nil }
            func createUser(data: UserData) throws {}
            func addSleep(data: SleepData) throws {}
            func deleteSleep(sleep data: SleepData) throws {}
            func getExercises() throws -> [ExerciseData] { return [] }
            func addExercise(data: ExerciseData) throws {}
            func deleteExercise(exercise data: ExerciseData) throws {}
        }
        
        let mockModelService = MockModelService()
        
        // When
        let viewModel = SleepViewModel(modelService: mockModelService)
        
        // Then
        XCTAssertEqual(viewModel.sleepSessions.count, 0, "Sleep sessions should be empty")
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        
        if let error = viewModel.error {
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
    
    func test_ClearAddSleepFields_ResetsAllFields() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        let modelService = ModelService(context: context)
        let viewModel = SleepViewModel(modelService: modelService)
        
        // Set some values
        viewModel.startDate = Date(timeIntervalSince1970: 0) // A specific date for testing
        viewModel.duration = 480
        viewModel.quality = 8
        
        // When
        viewModel.clearAddSleepFields()
        
        // Then
        XCTAssertNotEqual(viewModel.startDate, Date(timeIntervalSince1970: 0), "Date should be reset to current date")
        XCTAssertEqual(viewModel.duration, 0, "Duration should be reset to 0")
        XCTAssertEqual(viewModel.quality, 0, "Quality should be reset to 0")
    }
    
    func test_AddSleep_SuccessfullyAddsSleepSessionAndClearsFields() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        _ = createUser(context: context)
        let modelService = ModelService(context: context)
        
        let viewModel = SleepViewModel(modelService: modelService)
        // Clear initial sessions (fetchSleepSessions is called in init)
        viewModel.sleepSessions = []
        
        // Set sleep data
        viewModel.startDate = Date()
        viewModel.duration = 480 // 8 hours
        viewModel.quality = 7
        
        // When
        let result = viewModel.addSleep(duration: 480)
        
        // Then
        XCTAssertTrue(result, "addSleep should return true on success")
        XCTAssertEqual(viewModel.sleepSessions.count, 1, "Should have one sleep session")
        XCTAssertEqual(viewModel.sleepSessions[0].duration, 480, "Duration should match")
        XCTAssertEqual(viewModel.sleepSessions[0].quality, 7, "Quality should match")
        
        // Verify fields were cleared
        XCTAssertEqual(viewModel.duration, 0, "Duration should be cleared")
        XCTAssertEqual(viewModel.quality, 0, "Quality should be cleared")
    }
    
    func test_AddSleep_HandlesErrorWhenNoUser() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Don't create a user - this should cause an error
        let modelService = ModelService(context: context)
        
        let viewModel = SleepViewModel(modelService: modelService)
        // Clear initial state
        viewModel.sleepSessions = []
        viewModel.error = nil
        
        // Set sleep data
        viewModel.startDate = Date()
        viewModel.duration = 480
        viewModel.quality = 8
        
        // When
        let result = viewModel.addSleep(duration: 480)
        
        // Then
        XCTAssertFalse(result, "addSleep should return false on error")
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        
        if let error = viewModel.error {
            switch error {
            case .noUserFound:
                // Expected error
                break
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        }
        
        XCTAssertEqual(viewModel.sleepSessions.count, 0, "No sleep sessions should be added")
    }
    
    func test_DeleteSleep_RemovesSleepSessionFromDatabase() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let user = createUser(context: context)
        let modelService = ModelService(context: context)
        
        // Add a sleep session to the database
        let sleep = addSleepToDatabase(
            context: context,
            user: user,
            duration: 480,
            quality: 8,
            startDate: Date()
        )
        
        // Create the view model
        let viewModel = SleepViewModel(modelService: modelService)
        
        // Load sleep sessions to verify initial state
        viewModel.fetchSleepSessions()
        XCTAssertEqual(viewModel.sleepSessions.count, 1, "Should have one sleep session initially")
        
        // Create the sleep data to delete
        let sleepToDelete = SleepData(
            id: sleep.id!,
            duration: Int(sleep.duration),
            quality: Int(sleep.quality),
            startDate: sleep.startDate!
        )
        
        // When
        viewModel.deleteSleep(sleep: sleepToDelete)
        
        // Then
        XCTAssertEqual(viewModel.sleepSessions.count, 0, "Sleep session should be deleted")
        XCTAssertNil(viewModel.error, "Error should be nil")
        
        // Verify directly from database
        let fetchRequest = Sleep.fetchRequest()
        let count = try! context.count(for: fetchRequest)
        XCTAssertEqual(count, 0, "Database should have no sleep sessions")
    }
    
    func test_DeleteSleep_HandlesErrors() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        _ = createUser(context: context)
        let modelService = ModelService(context: context)
        
        // Create the view model
        let viewModel = SleepViewModel(modelService: modelService)
        
        // Create a sleep data with a non-existent ID
        let nonExistentSleep = SleepData(
            id: UUID().uuidString,
            duration: 480,
            quality: 8,
            startDate: Date()
        )
        
        // When
        viewModel.deleteSleep(sleep: nonExistentSleep)
        
        // Then
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        if let error = viewModel.error {
            XCTAssertTrue(error == .exerciseNotFound, "Should be exerciseNotFound error")
        } else {
            XCTFail("Error should be AppError.exerciseNotFound")
        }
    }
}
