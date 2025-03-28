//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 04/03/2025.
//

import XCTest
import CoreData
@testable import Arista

class ModelServiceSleepTests: XCTestCase {

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

    private func addSleepSession(context: NSManagedObjectContext, user: User, startDate: Date, duration: Int64, quality: Int64) -> Sleep {
        let newSleep = Sleep(context: context)
        newSleep.startDate = startDate
        newSleep.duration = duration
        newSleep.quality = quality
        newSleep.id = UUID().uuidString
        newSleep.user = user

        try! context.save()
        return newSleep
    }

    func test_WhenNoSleepSessionsInDatabase_GetSleepSessions_ReturnEmptyList() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let modelService = ModelService(context: context)
        
        // Create a user (required for the relationship)
        let _ = createUser(context: context)

        // When
        let sleepSessions = try! modelService.getSleepSessions()

        // Then
        XCTAssertTrue(sleepSessions.isEmpty, "Sleep sessions should be empty")
    }

    func test_WhenOneSleepSessionInDatabase_GetSleepSessions_ReturnListContainingTheSession() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        let user = createUser(context: context)
        
        let startDate = Date()
        let duration: Int64 = 8 * 60 // 8 hours in minutes
        let quality: Int64 = 5

        let sleepSession = addSleepSession(context: context, user: user, startDate: startDate, duration: duration, quality: quality)
        let modelService = ModelService(context: context)

        // When
        let sleepSessions = try! modelService.getSleepSessions()

        // Then
        XCTAssertEqual(sleepSessions.count, 1, "Should be one sleep session")
        let sleepData = sleepSessions.first!
        XCTAssertEqual(sleepData.startDate, startDate, "Start date should match")
        XCTAssertEqual(Int64(sleepData.duration), duration, "Duration should match")
        XCTAssertEqual(Int64(sleepData.quality), quality, "Quality should match")
        XCTAssertEqual(sleepData.id, sleepSession.id, "ID should match")
    }

    func test_WhenMultipleSleepSessionsInDatabase_GetSleepSessions_ReturnListInCorrectOrder() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        let user = createUser(context: context)

        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24)) // Yesterday
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2)) // Two days ago

        let duration1: Int64 = 8 * 60
        let duration2: Int64 = 7 * 60
        let duration3: Int64 = 6 * 60

        let quality1: Int64 = 5
        let quality2: Int64 = 4
        let quality3: Int64 = 3

        _ = addSleepSession(context: context, user: user, startDate: date1, duration: duration1, quality: quality1)
        _ = addSleepSession(context: context, user: user, startDate: date2, duration: duration2, quality: quality2)
        _ = addSleepSession(context: context, user: user, startDate: date3, duration: duration3, quality: quality3)

        let modelService = ModelService(context: context)

        // When
        let sleepSessions = try! modelService.getSleepSessions()

        // Then
        XCTAssertEqual(sleepSessions.count, 3, "Should be three sleep sessions")
        XCTAssertEqual(sleepSessions[0].startDate, date1, "First session should be most recent")
        XCTAssertEqual(sleepSessions[1].startDate, date2, "Second session should be the middle date")
        XCTAssertEqual(sleepSessions[2].startDate, date3, "Third session should be the oldest")
    }
    
    func test_AddSleep_WhenUserExists_ShouldAddSleepSession() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        _ = createUser(context: context)
        
        let modelService = ModelService(context: context)
        let sleepData = SleepData(
            id: UUID().uuidString,
            duration: 480, // 8 hours in minutes
            quality: 8,
            startDate: Date()
        )
        
        // When
        do {
            try modelService.addSleep(data: sleepData)
            
            // Then
            let sleepSessions = try modelService.getSleepSessions()
            XCTAssertEqual(sleepSessions.count, 1, "Should be one sleep session")
            XCTAssertEqual(sleepSessions[0].duration, sleepData.duration, "Duration should match")
            XCTAssertEqual(sleepSessions[0].quality, sleepData.quality, "Quality should match")
        } catch {
            XCTFail("Failed to add sleep session: \(error)")
        }
    }
    
    func test_AddSleep_WhenNoUserExists_ShouldThrowError() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Don't create a user - we want to test the no user case
        let modelService = ModelService(context: context)
        let sleepData = SleepData(
            id: UUID().uuidString,
            duration: 480,
            quality: 8,
            startDate: Date()
        )
        
        // When & Then
        XCTAssertThrowsError(try modelService.addSleep(data: sleepData)) { error in
            if let appError = error as? AppError {
                XCTAssertTrue(appError == .noUserFound, "Should throw noUserFound error")
            } else {
                XCTFail("Expected AppError.noUserFound but got different error type: \(error)")
            }
        }
    }
    
    func test_DeleteSleep_WhenSleepExists_ShouldRemoveSleepSession() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        let user = createUser(context: context)
        
        let startDate = Date()
        let sleepSession = addSleepSession(context: context, user: user, startDate: startDate, duration: 480, quality: 8)
        
        let modelService = ModelService(context: context)
        let sleepData = SleepData(
            id: sleepSession.id!,
            duration: Int(sleepSession.duration),
            quality: Int(sleepSession.quality),
            startDate: sleepSession.startDate!
        )
        
        // Verify sleep session exists
        let sessions = try! modelService.getSleepSessions()
        XCTAssertEqual(sessions.count, 1, "Should have one sleep session before deletion")
        
        // When
        do {
            try modelService.deleteSleep(sleep: sleepData)
            
            // Then
            let updatedSessions = try modelService.getSleepSessions()
            XCTAssertEqual(updatedSessions.count, 0, "Sleep session should be deleted")
        } catch {
            XCTFail("Failed to delete sleep session: \(error)")
        }
    }
    
    func test_DeleteSleep_WhenSleepDoesNotExist_ShouldThrowError() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user
        let _ = createUser(context: context)
        
        let modelService = ModelService(context: context)
        let nonExistentSleepData = SleepData(
            id: UUID().uuidString,
            duration: 480,
            quality: 8,
            startDate: Date()
        )
        
        // When & Then
        XCTAssertThrowsError(try modelService.deleteSleep(sleep: nonExistentSleepData)) { error in
            if let appError = error as? AppError {
                XCTAssertTrue(appError == .exerciseNotFound, "Should throw exerciseNotFound error")
            } else {
                XCTFail("Expected AppError.exerciseNotFound but got different error type: \(error)")
            }
        }
    }
}
