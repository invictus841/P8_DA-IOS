//
//  ModelService+Exercise.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation
import CoreData

extension ModelService {

    // MARK: - Exercise Operations

    func addExercise(data: ExerciseData) throws {
          // Fetch the user to connect the new Exercise with existing user
        guard (try getUser()) != nil else {
              throw AppError.noUserFound // Or a custom error specific to this case.
          }
          let newExercise = Exercise(context: viewContext)
        newExercise.category = data.category
        newExercise.duration = Int64(data.duration)
        newExercise.intensity = Int64(data.intensity)
        newExercise.startDate = data.startDate
        newExercise.id = data.id
        newExercise.user = try getUserCoreData()//set core data type, not DTO
        try viewContext.save()
    }
    
    func getExercises() throws -> [ExerciseData] {
            let request = Exercise.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.startDate, ascending: false)]

            let exercises = try viewContext.fetch(request)
            return exercises.map { exercise in
                ExerciseData(
                    id:exercise.id ?? UUID().uuidString, //Get the string ID, and avoid the crash.
                    category: exercise.category ?? "",
                    startDate: exercise.startDate ?? Date(),
                    duration: Int(exercise.duration),
                    intensity: Int(exercise.intensity)
                )
            }
        }
    
    // MARK: - Delete Exercise

        func deleteExercise(exercise data: ExerciseData) throws {
            let request = Exercise.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", data.id as CVarArg) //Find the id
            //Check if the exercise exist
            guard let exercise = try viewContext.fetch(request).first else {
                throw AppError.exerciseNotFound
            }
            
            viewContext.delete(exercise)
            try viewContext.save()
            
        }
}
