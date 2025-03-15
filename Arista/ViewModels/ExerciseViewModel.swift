//
//  ExerciseViewModel.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation // No import CoreData!

class ExerciseViewModel: ObservableObject {
    @Published var category: String = ""  // For AddExerciseView
    @Published var startDate: Date = Date() // For AddExerciseView
    @Published var duration: Int = 0       // For AddExerciseView
    @Published var intensity: Int = 0      // For AddExerciseView

    @Published var exercises: [ExerciseData] = [] // For ExerciseListView

    @Published var error: AppError? = nil

    private let modelService: ModelServiceProtocol // Inject ModelServiceProtocol, NO Core Data

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
        loadExercises()
    }

    // MARK: - Add Exercise Functionality

    func addExercise() -> Bool {
        let exerciseData = ExerciseData(
            id: UUID().uuidString,
            category: category,
            startDate: startDate,
            duration: duration,
            intensity: intensity
        )

        do {
            try modelService.addExercise(data: exerciseData)
            //Clear the fields after the action is done.
            clearAddExerciseFields()
            loadExercises() // Refresh the list after adding
            return true
        } catch {
            if let appError = error as? AppError {
                self.error = appError
            } else {
                self.error = .coreDataError(error)
            }
            return false
        }
    }

    //Clears the add exercise fields so that the previously entered data is not there.
    func clearAddExerciseFields() {
        category = ""
        startDate = Date()
        duration = 0
        intensity = 0
    }

    // MARK: - Exercise List Functionality

    func loadExercises() {
        do {
            exercises = try modelService.getExercises()
        } catch {
            self.error = error as? AppError //Ensure AppError
        }
    }

    func deleteExercise(exercise: ExerciseData) {
        do {
            try modelService.deleteExercise(exercise: exercise)
            print("Exercise deleted successfully!")
            
            loadExercises() // Refreshes the list for the UI
        } catch {
            self.error = error as? AppError
        }
    }
}
