//
//  ModelService.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation
import CoreData

protocol ModelServiceProtocol {
    func createUser(data: UserData) throws
    func getUser() throws -> UserData?
    func addExercise(data: ExerciseData) throws
    func getExercises() throws -> [ExerciseData]
    func addSleep(data: SleepData) throws
    func getSleepSessions() throws -> [SleepData]
    func deleteExercise(exercise: ExerciseData) throws
}

class ModelService: ModelServiceProtocol {
    let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
}
