//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 04/03/2025.
//

import XCTest
import CoreData
@testable import Arista

struct SleepRepositoryTests {

    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Sleep.fetchRequest()
        let objects = try! context.fetch(fetchRequest)

        for sleep in objects {
            context.delete(sleep)
        }

        try! context.save()
    }

    private func addSleepSession(context: NSManagedObjectContext, startDate: Date, duration: Int64, quality: Int64) {
        let newSleep = Sleep(context: context)
        newSleep.startDate = startDate
        newSleep.duration = duration
        newSleep.quality = quality

        try! context.save()
    }

    func test_WhenNoSleepSessionsInDatabase_GetSleepSessions_ReturnEmptyList() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let repository = SleepRepository(viewContext: context)

        // When
        let sleepSessions = try! repository.getSleepSessions()

        // Then
        XCTAssertTrue(sleepSessions.isEmpty, "Sleep sessions should be empty")
    }

    func test_WhenOneSleepSessionInDatabase_GetSleepSessions_ReturnListContainingTheSession() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let startDate = Date()
        let duration: Int64 = 8 * 60 // 8 hours in minutes
        let quality: Int64 = 5

        addSleepSession(context: context, startDate: startDate, duration: duration, quality: quality)
        let repository = SleepRepository(viewContext: context)

        // When
        let sleepSessions = try! repository.getSleepSessions()

        // Then
        XCTAssertEqual(sleepSessions.count, 1, "Should be one sleep session")
        let sleepSession = sleepSessions.first!
        XCTAssertEqual(sleepSession.startDate, startDate, "Start date should match")
        XCTAssertEqual(sleepSession.duration, duration, "Duration should match")
        XCTAssertEqual(sleepSession.quality, quality, "Quality should match")
    }

    func test_WhenMultipleSleepSessionsInDatabase_GetSleepSessions_ReturnListInCorrectOrder() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)

        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24)) // Yesterday
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2)) // Two days ago

        let duration1: Int64 = 8 * 60
        let duration2: Int64 = 7 * 60
        let duration3: Int64 = 6 * 60

        let quality1: Int64 = 5
        let quality2: Int64 = 4
        let quality3: Int64 = 3

        addSleepSession(context: context, startDate: date1, duration: duration1, quality: quality1)
        addSleepSession(context: context, startDate: date2, duration: duration2, quality: quality2)
        addSleepSession(context: context, startDate: date3, duration: duration3, quality: quality3)

        let repository = SleepRepository(viewContext: context)

        // When
        let sleepSessions = try! repository.getSleepSessions()

        // Then
        XCTAssertEqual(sleepSessions.count, 3, "Should be three sleep sessions")
        XCTAssertEqual(sleepSessions[0].startDate, date1, "First session should be most recent")
        XCTAssertEqual(sleepSessions[1].startDate, date2, "Second session should be the middle date")
        XCTAssertEqual(sleepSessions[2].startDate, date3, "Third session should be the oldest")
    }
}
