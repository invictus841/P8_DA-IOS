//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
//import CoreData

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddExerciseViewModel
    @State private var showingErrorAlert = false

    let durationRange = 0...120
    let intensityRange = 0...10

    let exerciseCategories = ["Football", "Natation", "Running", "Marche", "Cyclisme", "Divers"]

    @State private var isFormValid = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        Picker("Catégorie", selection: $viewModel.category) {
                            ForEach(exerciseCategories, id: \.self) { category in
                                Text(category)
                            }
                        }
                        .foregroundColor(.primary)
                    } header: {
                        Text("Catégorie")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    Section {
                        DatePicker(
                            "Heure de démarrage",
                            selection: $viewModel.startTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .foregroundColor(.primary)
                    } header: {
                        Text("Heure de démarrage")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    Section {
                        Picker("Durée (en minutes)", selection: $viewModel.duration) {
                            ForEach(durationRange, id: \.self) { duration in
                                Text("\(duration) minutes")
                            }
                        }
                        .foregroundColor(.primary)
                    } header: {
                        Text("Durée")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    Section {
                        Picker("Intensité (0 à 10)", selection: $viewModel.intensity) {
                            ForEach(intensityRange, id: \.self) { intensity in
                                Text("\(intensity)")
                            }
                        }
                        .foregroundColor(.primary)
                    } header: {
                        Text("Intensité")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .onChange(of: viewModel.category) { oldValue, newValue in validateForm() }
                .onChange(of: viewModel.startTime) { oldValue, newValue in validateForm() }
                .onChange(of: viewModel.duration) { oldValue, newValue in validateForm() }
                .onChange(of: viewModel.intensity) { oldValue, newValue in validateForm() }

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
                .padding(.bottom)

            }
            .navigationTitle("Nouvel Exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))

            .onChange(of: viewModel.error) {
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

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PersistenceController.preview.container.viewContext))
}
