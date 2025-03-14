//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation // No import CoreData!

class AddExerciseViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var startTime: Date = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 0

    @Published var error: AppError? = nil

    private let modelService: ModelServiceProtocol // Inject ModelServiceProtocol, NO Core Data

    //Removed context as it is not required here

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
    }

    func addExercise() -> Bool {
        let exerciseData = ExerciseData(
            category: category,
            startTime: startTime,
            duration: duration,
            intensity: intensity
        )

        do {
            try modelService.addExercise(data: exerciseData)
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
}
