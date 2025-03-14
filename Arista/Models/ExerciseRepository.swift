//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import Foundation
import CoreData

struct ExerciseRepository {
    let viewContext: NSManagedObjectContext
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    func getExercise() throws -> [Exercise] {
        let request = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Exercise>(\.startDate, order: .reverse))]
        return try viewContext.fetch(request)
    }
    
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date) throws {
        print("addExercise called with category: \(category)")
        let newExercise = Exercise(context: viewContext)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate

        do {
           newExercise.user = try UserRepository(viewContext: viewContext).getUser()
        } catch {
           print("cant retrieve user")
           throw AppError.noUserFound
        }

        try viewContext.save()
        print("addExercise completed successfully")
    }
}

