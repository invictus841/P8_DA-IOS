//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import XCTest
import CoreData
@testable import Arista

class SleepHistoryViewModelTests: XCTestCase {

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

    func test_Init_SetsInitialState() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext

        // When
        let viewModel = SleepViewModel(context: context)

        // Then
        XCTAssertTrue(viewModel.sleepSessions.isEmpty, "Sleep sessions should be initially empty")
        XCTAssertNil(viewModel.error, "Error should be initially nil")
    }

    func test_FetchSleepSessions_SuccessfullyFetchesData() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let startDate = Date()
        let duration: Int64 = 8 * 60
        let quality: Int64 = 5
        addSleepSession(context: context, startDate: startDate, duration: duration, quality: quality)

        // When
        let viewModel = SleepViewModel(context: context)
        viewModel.fetchSleepSessions() // Call the function *after* initialization

        // Then
        XCTAssertEqual(viewModel.sleepSessions.count, 1, "Sleep sessions count should be 1")
        XCTAssertNotNil(viewModel.sleepSessions.first, "First element should not be nil")
        let sleepSession = viewModel.sleepSessions.first!
        XCTAssertEqual(sleepSession.startDate, startDate, "Start date should match")
        XCTAssertEqual(sleepSession.duration, duration, "Duration should match")
        XCTAssertEqual(sleepSession.quality, quality, "Quality should match")
        XCTAssertNil(viewModel.error, "Error should be nil")
    }
}
