//
//  AddExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Alexandre Talatinian on 04/03/2025.
//

import XCTest
import CoreData
@testable import Arista

class ExerciseViewModelTests: XCTestCase {
    
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
    
    private func createUser(context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.firstName = "Test"
        user.lastName = "User"
        user.id = UUID().uuidString
        
        try! context.save()
        return user
    }
    
    private func addExerciseToDatabase(context: NSManagedObjectContext, user: User, category: String, duration: Int, intensity: Int, startDate: Date) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID().uuidString
        exercise.category = category
        exercise.duration = Int64(duration)
        exercise.intensity = Int64(intensity)
        exercise.startDate = startDate
        exercise.user = user
        
        try! context.save()
        return exercise
    }
    
    func test_LoadExercises_LoadsExercisesFromDatabase() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let user = createUser(context: context)
        let modelService = ModelService(context: context)
        
        // Add some exercises to the database
        _ = addExerciseToDatabase(
            context: context,
            user: user,
            category: "Running",
            duration: 30,
            intensity: 5,
            startDate: Date()
        )
        
        _ = addExerciseToDatabase(
            context: context,
            user: user,
            category: "Swimming",
            duration: 45,
            intensity: 3,
            startDate: Date(timeIntervalSinceNow: -3600)
        )
        
        // Create the view model - this will automatically call loadExercises() in init
        let viewModel = ExerciseViewModel(modelService: modelService)
        
        // Initial state should have the exercises we added
        XCTAssertEqual(viewModel.exercises.count, 2, "Should have loaded two exercises during initialization")
        
        // When - clear the array and reload to test the loadExercises method explicitly
        viewModel.exercises = []
        XCTAssertEqual(viewModel.exercises.count, 0, "Exercises should be empty after manual clearing")
        
        viewModel.loadExercises()
        
        // Then
        XCTAssertEqual(viewModel.exercises.count, 2, "Should load two exercises")
        XCTAssertEqual(viewModel.exercises[0].category, "Running", "First exercise should be Running")
        XCTAssertEqual(viewModel.exercises[1].category, "Swimming", "Second exercise should be Swimming")
        XCTAssertNil(viewModel.error, "Error should be nil")
    }
    
    func test_DeleteExercise_RemovesExerciseFromDatabase() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        let user = createUser(context: context)
        let modelService = ModelService(context: context)
        
        // Add an exercise to the database
        let exercise = addExerciseToDatabase(
            context: context,
            user: user,
            category: "Yoga",
            duration: 60,
            intensity: 2,
            startDate: Date()
        )
        
        // Create the view model
        let viewModel = ExerciseViewModel(modelService: modelService)
        
        // Load exercises to verify initial state
        viewModel.loadExercises()
        XCTAssertEqual(viewModel.exercises.count, 1, "Should have one exercise initially")
        
        // Create the exercise data to delete
        let exerciseToDelete = ExerciseData(
            id: exercise.id!,
            category: exercise.category!,
            startDate: exercise.startDate!,
            duration: Int(exercise.duration),
            intensity: Int(exercise.intensity)
        )
        
        // When
        viewModel.deleteExercise(exercise: exerciseToDelete)
        
        // Then
        XCTAssertEqual(viewModel.exercises.count, 0, "Exercise should be deleted")
        XCTAssertNil(viewModel.error, "Error should be nil")
        
        // Verify directly from database
        let fetchRequest = Exercise.fetchRequest()
        let count = try! context.count(for: fetchRequest)
        XCTAssertEqual(count, 0, "Database should have no exercises")
    }
    
    func test_DeleteExercise_HandlesErrors() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        _ = createUser(context: context)
        let modelService = ModelService(context: context)
        
        // Create the view model
        let viewModel = ExerciseViewModel(modelService: modelService)
        
        // Create an exercise data with a non-existent ID
        let nonExistentExercise = ExerciseData(
            id: UUID().uuidString,
            category: "Running",
            startDate: Date(),
            duration: 30,
            intensity: 5
        )
        
        // When
        viewModel.deleteExercise(exercise: nonExistentExercise)
        
        // Then
        XCTAssertNotNil(viewModel.error, "Error should not be nil")
        if let error = viewModel.error {
            XCTAssertTrue(error == .exerciseNotFound, "Should be exerciseNotFound error")
        } else {
            XCTFail("Error should be AppError.exerciseNotFound")
        }
    }
    
    func test_ClearAddExerciseFields_ResetsAllFields() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        let modelService = ModelService(context: context)
        let viewModel = ExerciseViewModel(modelService: modelService)
        
        // Set some values
        viewModel.category = "Running"
        viewModel.startDate = Date(timeIntervalSince1970: 0) // A specific date for testing
        viewModel.duration = 30
        viewModel.intensity = 5
        
        // When
        viewModel.clearAddExerciseFields()
        
        // Then
        XCTAssertEqual(viewModel.category, "", "Category should be reset to empty string")
        XCTAssertNotEqual(viewModel.startDate, Date(timeIntervalSince1970: 0), "Date should be reset to current date")
        XCTAssertEqual(viewModel.duration, 0, "Duration should be reset to 0")
        XCTAssertEqual(viewModel.intensity, 0, "Intensity should be reset to 0")
    }
    
    func test_AddExercise_SuccessfullyAddsExerciseAndClearsFields() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        _ = createUser(context: context)
        let modelService = ModelService(context: context)
        
        let viewModel = ExerciseViewModel(modelService: modelService)
        // Clear initial exercises (loadExercises is called in init)
        viewModel.exercises = []
        
        // Set exercise data
        viewModel.category = "Running"
        viewModel.startDate = Date()
        viewModel.duration = 30
        viewModel.intensity = 5
        
        // When
        let result = viewModel.addExercise()
        
        // Then
        XCTAssertTrue(result, "addExercise should return true on success")
        XCTAssertEqual(viewModel.exercises.count, 1, "Should have one exercise")
        XCTAssertEqual(viewModel.exercises[0].category, "Running", "Category should match")
        XCTAssertEqual(viewModel.exercises[0].duration, 30, "Duration should match")
        XCTAssertEqual(viewModel.exercises[0].intensity, 5, "Intensity should match")
        
        // Verify fields were cleared
        XCTAssertEqual(viewModel.category, "", "Category should be cleared")
        XCTAssertEqual(viewModel.duration, 0, "Duration should be cleared")
        XCTAssertEqual(viewModel.intensity, 0, "Intensity should be cleared")
    }
    
    func test_AddExercise_HandlesErrorWhenNoUser() {
        // Given
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        emptyEntities(context: context)
        
        // Don't create a user - this should cause an error
        let modelService = ModelService(context: context)
        
        let viewModel = ExerciseViewModel(modelService: modelService)
        // Clear initial state
        viewModel.exercises = []
        viewModel.error = nil
        
        // Set exercise data
        viewModel.category = "Running"
        viewModel.startDate = Date()
        viewModel.duration = 30
        viewModel.intensity = 5
        
        // When
        let result = viewModel.addExercise()
        
        // Then
        XCTAssertFalse(result, "addExercise should return false on error")
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
        
        XCTAssertEqual(viewModel.exercises.count, 0, "No exercises should be added")
    }
}
