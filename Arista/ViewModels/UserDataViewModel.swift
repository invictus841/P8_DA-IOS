//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class UserDataViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    @Published var error: Error?

    private let modelService: ModelServiceProtocol

    init(modelService: ModelServiceProtocol) {
        self.modelService = modelService
        fetchUserData()
    }

    private func fetchUserData() {
        do {
            if let user = try modelService.getUser() {
                
                firstName = user.firstName
                lastName = user.lastName
            } else {
                
                firstName = ""
                lastName = ""
                error = AppError.noUserFound
            }
        } catch {
            self.error = error as? AppError
        }
    }
}
