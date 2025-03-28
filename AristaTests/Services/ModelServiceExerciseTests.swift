//
//  ExerciseRepositoryTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 04/03/2025.
//

import XCTest
@testable import Arista
import CoreData

class ModelServiceExerciseTests: XCTestCase {
    private func emptyEntities(context: NSManagedObjectContext) {
        // Clear exercise entities
        let exerciseFetchRequest = Exercise.fetchRequest()
        let exerciseObjects = try! context.fetch(exerciseFetchRequest)
        
        for exercise in exerciseObjects {
            context.delete(exercise)
        }
        
        // Clear user entities
        let userFetchRequest = User.fetchRequest()
        let userObjects = try! context.fetch(userFetchRequest)
        
        for user in userObjects {
            context.delete(user)
        }
        
        try! context.save()
    }
    
    @discardableResult
    private func createUser(context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.firstName = "Test"
        user.lastName = "User"
        user.id = UUID().uuidString
        
        try! context.save()
        return user
    }
    
    private func addExercise(context: NSManagedObjectContext, user: User, category: String, duration: Int, intensity: Int, startDate: Date) -> Exercise {
        let newExercise = Exercise(context: context)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.id = UUID().uuidString
        newExercise.user = user
        
        try! context.save()
        return newExercise
    }
    
    func test_WhenNoExerciseIsInDatabase_GetExercise_ReturnEmptyList() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let modelService = ModelService(context: context)
        
        // Create a user (required for relationship but we won't add exercises)
        let _ = createUser(context: context)
        
        // When
        let exercises = try! modelService.getExercises()
        
        // Then
        XCTAssertTrue(exercises.isEmpty, "Exercise list should be empty")
    }
    
    func test_WhenAddingOneExerciseInDatabase_GetExercise_ReturnAListContainingTheExercise() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        let user = createUser(context: context)
        
        let date = Date()
        let category = "Football"
        let duration = 10
        let intensity = 5
        
        let _ = addExercise(
            context: context,
            user: user,
            category: category,
            duration: duration,
            intensity: intensity,
            startDate: date
        )
        
        let modelService = ModelService(context: context)
        
        // When
        let exercises = try! modelService.getExercises()
        
        // Then
        XCTAssertFalse(exercises.isEmpty, "Exercise list should not be empty")
        XCTAssertEqual(exercises.first?.category, category, "Category should match")
        XCTAssertEqual(exercises.first?.duration, duration, "Duration should match")
        XCTAssertEqual(exercises.first?.intensity, intensity, "Intensity should match")
        XCTAssertEqual(exercises.first?.startDate, date, "Start date should match")
    }
    
    func test_WhenAddingMultipleExerciseInDatabase_GetExercise_ReturnAListContainingTheExerciseInTheRightOrder() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        let user = createUser(context: context)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        let _ = addExercise(
            context: context,
            user: user,
            category: "Football",
            duration: 10,
            intensity: 5,
            startDate: date1
        )
        
        let _ = addExercise(
            context: context,
            user: user,
            category: "Running",
            duration: 120,
            intensity: 1,
            startDate: date3
        )
        
        let _ = addExercise(
            context: context,
            user: user,
            category: "Fitness",
            duration: 30,
            intensity: 5,
            startDate: date2
        )
        
        let modelService = ModelService(context: context)
        
        // When
        let exercises = try! modelService.getExercises()
        
        // Then
        XCTAssertEqual(exercises.count, 3, "Should be three exercises")
        XCTAssertEqual(exercises[0].category, "Football", "First exercise should be Football")
        XCTAssertEqual(exercises[1].category, "Fitness", "Second exercise should be Fitness")
        XCTAssertEqual(exercises[2].category, "Running", "Third exercise should be Running")
    }
    
    func test_AddExercise_AddsExerciseCorrectly() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        createUser(context: context)
        let modelService = ModelService(context: context)
        
        let testCategory = "Swimming"
        let testDuration = 45
        let testIntensity = 7
        let testDate = Date()
        let testId = UUID().uuidString
        
        let exerciseData = ExerciseData(
            id: testId,
            category: testCategory,
            startDate: testDate,
            duration: testDuration,
            intensity: testIntensity
        )
        
        // When
        do {
            try modelService.addExercise(data: exerciseData)
            
            // Then
            let exercises = try modelService.getExercises()
            
            XCTAssertEqual(exercises.count, 1, "Exercise should be added")
            let addedExercise = exercises.first!
            
            XCTAssertEqual(addedExercise.category, testCategory, "Category should match")
            XCTAssertEqual(addedExercise.duration, testDuration, "Duration should match")
            XCTAssertEqual(addedExercise.intensity, testIntensity, "Intensity should match")
            XCTAssertEqual(addedExercise.startDate, testDate, "Start date should match")
            XCTAssertEqual(addedExercise.id, testId, "ID should match")
        } catch {
            XCTFail("Failed to add exercise: \(error)")
        }
    }
    
    func test_AddExercise_ThrowsErrorWhenNoUserExists() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        let modelService = ModelService(context: context)
        
        let exerciseData = ExerciseData(
            id: UUID().uuidString,
            category: "Walking",
            startDate: Date(),
            duration: 30,
            intensity: 3
        )
        
        // When & Then
        XCTAssertThrowsError(try modelService.addExercise(data: exerciseData)) { error in
            if let appError = error as? AppError {
                XCTAssertTrue(appError == .noUserFound, "Should throw noUserFound error")
            } else {
                XCTFail("Expected AppError.noUserFound but got different error type: \(error)")
            }
        }
    }
    
    func test_DeleteExercise_WhenExerciseExists_ShouldRemoveExercise() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user first
        let user = createUser(context: context)
        
        // Add an exercise
        let exercise = addExercise(
            context: context,
            user: user,
            category: "Yoga",
            duration: 60,
            intensity: 2,
            startDate: Date()
        )
        
        let modelService = ModelService(context: context)
        let exerciseData = ExerciseData(
            id: exercise.id!,
            category: exercise.category!,
            startDate: exercise.startDate!,
            duration: Int(exercise.duration),
            intensity: Int(exercise.intensity)
        )
        
        // Verify exercise exists
        let exercises = try! modelService.getExercises()
        XCTAssertEqual(exercises.count, 1, "Should have one exercise before deletion")
        
        // When
        do {
            try modelService.deleteExercise(exercise: exerciseData)
            
            // Then
            let updatedExercises = try modelService.getExercises()
            XCTAssertEqual(updatedExercises.count, 0, "Exercise should be deleted")
        } catch {
            XCTFail("Failed to delete exercise: \(error)")
        }
    }
    
    func test_DeleteExercise_WhenExerciseDoesNotExist_ShouldThrowError() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Create a user
        let _ = createUser(context: context)
        
        let modelService = ModelService(context: context)
        let nonExistentExerciseData = ExerciseData(
            id: UUID().uuidString,
            category: "Running",
            startDate: Date(),
            duration: 30,
            intensity: 5
        )
        
        // When & Then
        XCTAssertThrowsError(try modelService.deleteExercise(exercise: nonExistentExerciseData)) { error in
            if let appError = error as? AppError {
                XCTAssertTrue(appError == .exerciseNotFound, "Should throw exerciseNotFound error")
            } else {
                XCTFail("Expected AppError.exerciseNotFound but got different error type: \(error)")
            }
        }
    }
}
