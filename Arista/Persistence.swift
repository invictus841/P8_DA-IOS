//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true, applyDefaultData: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            // Handle the error appropriately in a real app
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false, applyDefaultData: Bool = false) {
        container = NSPersistentContainer(name: "Arista")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error gracefully instead of fatalError
                print("Error loading persistent stores: \(error), \(error.userInfo)")

                // In a real application, you would present an error message to the user
                // and potentially offer options to retry loading the store or reset the app.
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true

        if applyDefaultData {
            do {
                let modelService = ModelService(context: container.viewContext)
                try modelService.applyDefaultData()
            } catch {
                print("Error applying default data: \(error)")
                // Handle or re-throw the error appropriately
            }
        }
    }
}
