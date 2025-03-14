//
//  ModelService.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation
import CoreData // Only import CoreData in this file!

// MARK: - Data Transfer Objects (DTOs)

// Define structs that mirror your Core Data entities, but without Core Data dependencies.
struct ExerciseData {
    let category: String
    let startTime: Date
    let duration: Int
    let intensity: Int
}

struct SleepData {
    let duration: Int
    let quality: Int // Assuming 'intensity' was a typo and you meant 'quality' for sleep
    let startDate: Date
}

struct UserData {
    let firstName: String
    let lastName: String
}

// MARK: - Model Service

class ModelService: ModelServiceProtocol { //Conform to protocol
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    // MARK: - User Operations

    func createUser(data: UserData) throws {
        let newUser = User(context: viewContext)
        newUser.firstName = data.firstName
        newUser.lastName = data.lastName

        try viewContext.save()
    }

    func getUser() throws -> UserData? {
        let request = User.fetchRequest()
        request.fetchLimit = 1

        guard let user = try viewContext.fetch(request).first else {
            return nil
        }

        return UserData(firstName: user.firstName ?? "", lastName: user.lastName ?? "")
    }

    // MARK: - Exercise Operations

    func addExercise(data: ExerciseData) throws {
        // Fetch the user to connect the new Exercise with existing user
        guard let user = try getUser() else {
            throw AppError.noUserFound // Or a custom error specific to this case.
        }
        let newExercise = Exercise(context: viewContext)
        newExercise.category = data.category
        newExercise.duration = Int64(data.duration)
        newExercise.intensity = Int64(data.intensity)
        newExercise.startDate = data.startTime
        newExercise.user = try getUserCoreData()//set core data type, not DTO
        try viewContext.save()
    }

    func getExercises() throws -> [ExerciseData] {
        let request = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.startDate, ascending: false)]

        let exercises = try viewContext.fetch(request)
        return exercises.map { exercise in
            ExerciseData(
                category: exercise.category ?? "",
                startTime: exercise.startDate ?? Date(),
                duration: Int(exercise.duration),
                intensity: Int(exercise.intensity)
            )
        }
    }

    // MARK: - Sleep Operations

    func addSleep(data: SleepData) throws {

        guard let user = try getUser() else {
            throw AppError.noUserFound // Or a custom error specific to this case.
        }
        let newSleep = Sleep(context: viewContext)
        newSleep.duration = Int64(data.duration)
        newSleep.quality = Int64(data.quality) // corrected intensity to quality
        newSleep.startDate = data.startDate
        newSleep.user = try getUserCoreData()//set core data type, not DTO

        try viewContext.save()
    }

    func getSleepSessions() throws -> [SleepData] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sleep.startDate, ascending: false)]

        let sleeps = try viewContext.fetch(request)
        return sleeps.map { sleep in
            SleepData(
                duration: Int(sleep.duration),
                quality: Int(sleep.quality), // corrected intensity to quality
                startDate: sleep.startDate ?? Date()
            )
        }
    }

     //Private Helper Methods to retrieve Core Data Types, rather than DTOs
    private func getUserCoreData() throws -> User? {
        let request = User.fetchRequest()
        request.fetchLimit = 1

        guard let user = try viewContext.fetch(request).first else {
            return nil
        }

        return user
    }
}

protocol ModelServiceProtocol {
    func createUser(data: UserData) throws
    func getUser() throws -> UserData?
    func addExercise(data: ExerciseData) throws
    func getExercises() throws -> [ExerciseData]
    func addSleep(data: SleepData) throws
    func getSleepSessions() throws -> [SleepData]
}
