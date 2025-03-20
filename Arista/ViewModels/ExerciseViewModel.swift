//
//  ExerciseViewModel.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation

class ExerciseViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var startDate: Date = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 0

    @Published var exercises: [ExerciseData] = []

    @Published var error: AppError? = nil

    private let modelService: ModelServiceProtocol

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
        loadExercises()
    }

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

            clearAddExerciseFields()
            loadExercises()
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

    func clearAddExerciseFields() {
        category = ""
        startDate = Date()
        duration = 0
        intensity = 0
    }

    func loadExercises() {
        do {
            exercises = try modelService.getExercises()
        } catch {
            self.error = error as? AppError
        }
    }

    func deleteExercise(exercise: ExerciseData) {
        do {
            try modelService.deleteExercise(exercise: exercise)
            print("Exercise deleted successfully!")
            
            loadExercises()
        } catch {
            self.error = error as? AppError
        }
    }
}
