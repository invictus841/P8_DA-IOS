//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class SleepViewModel: ObservableObject {
    @Published var sleepSessions = [SleepData]()
    @Published var error: AppError? = nil
    
    @Published var duration: Int = 0
    @Published var quality: Int = 0
    @Published var startDate: Date = Date()

    private let modelService: ModelServiceProtocol

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
        fetchSleepSessions()
    }

    func fetchSleepSessions() {
        do {
            sleepSessions = try modelService.getSleepSessions()
        } catch {
            self.error = error as? AppError
        }
    }
    
    func clearAddSleepFields() {
        startDate = Date()
        duration = 0
        quality = 0
    }
    
    func addSleep(duration:Int) -> Bool {
            let sleepData = SleepData(
                id: UUID().uuidString,
                duration: duration,
                quality: quality,
                startDate: startDate
            )

            do {
                try modelService.addSleep(data: sleepData)
                print("Sleep added successfully!")
                
                clearAddSleepFields()
                fetchSleepSessions()
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
    
    func deleteSleep(sleep: SleepData) {
        do {
            try modelService.deleteSleep(sleep: sleep)
            print("Sleep deleted successfully!")
            
            fetchSleepSessions()
        } catch {
            self.error = error as? AppError
        }
    }
}

//struct FakeSleepSession: Identifiable {
//    var id = UUID()
//    var startDate: Date = Date()
//    var duration: Int = 695
//    var quality: Int = (0...10).randomElement()!
//}
