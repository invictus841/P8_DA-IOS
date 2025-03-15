//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation // No CoreData!

class UserDataViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    @Published var error: Error?

    private let modelService: ModelServiceProtocol // Inject ModelServiceProtocol

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
        fetchUserData()
    }

    private func fetchUserData() {
        do {
            if let user = try modelService.getUser() { // Get UserData
                firstName = user.firstName
                lastName = user.lastName
            } else {
                // Handle the case where no user exists
                firstName = ""
                lastName = ""
                error = AppError.noUserFound
            }
        } catch {
            self.error = error as? AppError //Ensure it is an app error
        }
    }
}
