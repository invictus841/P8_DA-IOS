//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class SleepHistoryViewModel: ObservableObject {
    @Published var sleepSessions = [SleepData]() // Use SleepData DTO
    @Published var error: Error?

    private let modelService: ModelServiceProtocol // Inject ModelServiceProtocol

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
        fetchSleepSessions()
    }

    func fetchSleepSessions() {
        do {
            sleepSessions = try modelService.getSleepSessions() // Get SleepData
        } catch {
            self.error = error as? AppError //Ensure it is an app error
        }
    }
}

//struct FakeSleepSession: Identifiable {
//    var id = UUID()
//    var startDate: Date = Date()
//    var duration: Int = 695
//    var quality: Int = (0...10).randomElement()!
//}
