//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CoreData

class SleepHistoryViewModel: ObservableObject {
    @Published var sleepSessions = [Sleep]()
    @Published var error: Error?

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func fetchSleepSessions() {
        do {
            let data = SleepRepository(viewContext: viewContext)
            sleepSessions = try data.getSleepSessions()
        } catch {
            self.error = error
        }
    }
}

//struct FakeSleepSession: Identifiable {
//    var id = UUID()
//    var startDate: Date = Date()
//    var duration: Int = 695
//    var quality: Int = (0...10).randomElement()!
//}
