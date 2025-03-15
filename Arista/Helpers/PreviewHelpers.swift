//
//  PreviewHelpers.swift
//  Arista
//
//  Created by Alexandre Talatinian on 14/03/2025.
//

import Foundation
import CoreData

struct PreviewHelpers {
    static var previewContext: NSManagedObjectContext = {
        let persistenceController = PersistenceController.preview
        return persistenceController.container.viewContext
    }()

    static var previewModelService: ModelService {
        return ModelService(context: previewContext)
    }
}
