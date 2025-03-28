//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ExerciseViewModel
    @State private var showingErrorAlert = false

    let durationRange = 0...120
    let intensityRange = 0...10

    let exerciseCategories = ["Football", "Natation", "Running", "Marche", "Cyclisme", "Divers"]

    @State private var isFormValid = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("Catégorie", selection: $viewModel.category) {
                        ForEach(exerciseCategories, id: \.self) { category in
                            Text(category)
                        }
                    }

                    DatePicker(
                        "Heure de démarrage",
                        selection: $viewModel.startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    Picker("Durée (en minutes)", selection: $viewModel.duration) {
                        ForEach(durationRange, id: \.self) { duration in
                            Text("\(duration) minutes")
                        }
                    }

                    Picker("Intensité (0 à 10)", selection: $viewModel.intensity) {
                        ForEach(intensityRange, id: \.self) { intensity in
                            Text("\(intensity)")
                        }
                    }
                }
                .formStyle(.grouped)
                .onChange(of: viewModel.category) { oldValue, newValue in validateForm() }
                .onChange(of: viewModel.startDate) { oldValue, newValue in validateForm() }
                .onChange(of: viewModel.duration) { oldValue, newValue in validateForm() }
                .onChange(of: viewModel.intensity) { oldValue, newValue in validateForm() }

                Spacer()

                if !isFormValid {
                    Text("Veuillez remplir tous les champs pour ajouter l'exercice.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Button("Ajouter l'exercice") {
                    if viewModel.addExercise() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
            }
            .navigationTitle("Nouvel Exercice ...")
            .onChange(of: viewModel.error) { oldValue, newValue in
                showingErrorAlert = viewModel.error != nil
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.error?.localizedDescription ?? "Unknown Error"),
                    dismissButton: .default(Text("OK"), action: {
                        viewModel.error = nil
                        showingErrorAlert = false
                    })
                )
            }
        }
    }

    private func validateForm() {
        isFormValid = !viewModel.category.isEmpty && viewModel.duration > 0 && viewModel.intensity > 0
    }
}

