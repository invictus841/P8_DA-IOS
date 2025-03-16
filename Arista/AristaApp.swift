//
//  AristaApp.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

@main
struct AristaApp: App {
    let persistenceController = PersistenceController.shared

    private var exerciseViewModel: ExerciseViewModel {
        let modelService = ModelService(context: persistenceController.container.viewContext)
        return ExerciseViewModel(modelService: modelService)
    }
    
    private var userDataViewModel: UserDataViewModel {
        let modelService = ModelService(context: persistenceController.container.viewContext)
        return UserDataViewModel(modelService: modelService)
    }
    
    private var sleepHistoryViewModel: SleepViewModel {
        let modelService = ModelService(context: persistenceController.container.viewContext)
        return SleepViewModel(modelService: modelService)
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                UserDataView(viewModel: userDataViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Utilisateur", systemImage: "person")
                    }

                ExerciseListView(viewModel: exerciseViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Exercices", systemImage: "flame")
                    }

                SleepHistoryView(viewModel: sleepHistoryViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Sommeil", systemImage: "moon")
                    }

            }
        }
    }
}
