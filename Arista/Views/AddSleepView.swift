//
//  AddSleepView.swift
//  Arista
//
//  Created by Alexandre Talatinian on 15/03/2025.
//

import SwiftUI

struct AddSleepView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SleepViewModel
    @State private var showingErrorAlert = false

    @State private var sleepDurationHours: Int = 8
    @State private var sleepDurationMinutes: Int = 0
    let sleepHoursRange = 0...24
    let sleepMinutesRange = 0...59

    let qualityRange = 0...10

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Durée du Sommeil")) {
                        HStack {
                            Picker("Heures", selection: $sleepDurationHours) {
                                ForEach(sleepHoursRange, id: \.self) { hour in
                                    Text("\(hour) h")
                                }
                            }

                            Picker("Minutes", selection: $sleepDurationMinutes) {
                                ForEach(sleepMinutesRange, id: \.self) { minute in
                                    Text("\(minute) min")
                                }
                            }
                        }
                    }

                    Section(header: Text("Qualité du Sommeil (0 à 10)")) {
                        Picker("Qualité", selection: $viewModel.quality) {
                            ForEach(qualityRange, id: \.self) { quality in
                                Text("\(quality)")
                            }
                        }
                    }

                    Button("Ajouter le Sommeil") {
                        let totalMinutes = sleepDurationHours * 60 + sleepDurationMinutes
                        if viewModel.addSleep(duration: totalMinutes) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .formStyle(.grouped)
            }
            .navigationTitle("Nouveau Sommeil ...")
            .onChange(of: viewModel.error) {oldValue, newValue in
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
}

#Preview {
    AddSleepView(viewModel: SleepViewModel(modelService: PreviewHelpers.previewModelService))
}
