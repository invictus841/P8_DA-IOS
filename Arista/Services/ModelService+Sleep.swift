//
//  ModelService+Sleep.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation
import CoreData

extension ModelService {
    // MARK: - Sleep Operations
    
    func addSleep(data: SleepData) throws {
        
        guard (try getUser()) != nil else {
            throw AppError.noUserFound
        }
        let newSleep = Sleep(context: viewContext)
        newSleep.duration = Int64(data.duration)
        newSleep.quality = Int64(data.quality)
        newSleep.startDate = data.startDate
        newSleep.id = UUID().uuidString
        newSleep.user = try getUserCoreData()
        
        try viewContext.save()
    }
    
    func getSleepSessions() throws -> [SleepData] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sleep.startDate, ascending: false)]
        
        let sleeps = try viewContext.fetch(request)
        return sleeps.map { sleep in
            SleepData(
                id: sleep.id ?? UUID().uuidString,
                duration: Int(sleep.duration),
                quality: Int(sleep.quality),
                startDate: sleep.startDate ?? Date()
            )
        }
    }
    
    // MARK: - Default Data Operations
//            func applyDefaultData() throws {
//                   if try getUser() == nil {
//                       let initialUser = User(context: viewContext)
//                       initialUser.firstName = "Charlotte"
//                       initialUser.lastName = "Razoul"
//                        initialUser.id = UUID().uuidString //set the initial User to have the ID
//    
//                       if try getSleepSessions().isEmpty {
//                           let sleep1 = Sleep(context: viewContext)
//                           let sleep2 = Sleep(context: viewContext)
//                           let sleep3 = Sleep(context: viewContext)
//                           let sleep4 = Sleep(context: viewContext)
//                           let sleep5 = Sleep(context: viewContext)
//    
//                           let timeIntervalForADay: TimeInterval = 60 * 60 * 24
//    
//                           sleep1.duration = Int64((0...900).randomElement()!)
//                           sleep1.quality = Int64((0...10).randomElement()!)
//                           sleep1.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*5)
//                           sleep1.user = initialUser
//                            sleep1.id = UUID().uuidString // Set sleep Id
//                           sleep2.duration = Int64((0...900).randomElement()!)
//                           sleep2.quality = Int64((0...10).randomElement()!)
//                           sleep2.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*4)
//                           sleep2.user = initialUser
//                            sleep2.id = UUID().uuidString // Set sleep Id
//                           sleep3.duration = Int64((0...900).randomElement()!)
//                           sleep3.quality = Int64((0...10).randomElement()!)
//                           sleep3.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*3)
//                           sleep3.user = initialUser
//                           sleep3.id = UUID().uuidString // Set sleep Id
//                           sleep4.duration = Int64((0...900).randomElement()!)
//                           sleep4.quality = Int64((0...10).randomElement()!)
//                           sleep4.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*2)
//                           sleep4.user = initialUser
//                            sleep4.id = UUID().uuidString // Set sleep Id
//                           sleep5.duration = Int64((0...900).randomElement()!)
//                           sleep5.quality = Int64((0...10).randomElement()!)
//                           sleep5.startDate = Date(timeIntervalSinceNow: timeIntervalForADay)
//                           sleep5.user = initialUser
//                            sleep5.id = UUID().uuidString // Set sleep Id
//                       }
//    
//                       try viewContext.save()
//                   }
//               }
    
    func deleteSleep(sleep data: SleepData) throws {
            let request = Sleep.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", data.id)
            //Check if the exercise exist
            guard let sleep = try viewContext.fetch(request).first else {
                throw AppError.exerciseNotFound
            }

            viewContext.delete(sleep)
            try viewContext.save()

        }
}
