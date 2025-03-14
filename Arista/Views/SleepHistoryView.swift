//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct SleepHistoryView: View {
    @ObservedObject var viewModel: SleepHistoryViewModel

        var body: some View {
            
            VStack {
                if !viewModel.sleepSessions.isEmpty {
                    List(viewModel.sleepSessions) { session in
                        HStack {
                            QualityIndicator(quality: session.quality)
                                .padding()
                            VStack(alignment: .leading) {
                                Text("Début : \(session.startDate?.formatted() ?? "date non définie")")
                                Text("Durée : \(session.duration/60) heures")
                            }
                        }
                    }
                } else {
                    Text("Ajoutez votre première nuit de sommeil!")
                }
            }
            .navigationTitle("Historique de Sommeil")
        }
}

struct QualityIndicator: View {
    let quality: Int64

    var body: some View {
        ZStack {
            Circle()
                .stroke(qualityColor(Int(quality)), lineWidth: 5)
                .foregroundColor(qualityColor(Int(quality)))
                .frame(width: 30, height: 30)
            Text("\(quality)")
                .foregroundColor(qualityColor(Int(quality)))
        }
    }

    func qualityColor(_ quality: Int) -> Color {
        switch (10-quality) {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    SleepHistoryView(viewModel: SleepHistoryViewModel(context: PersistenceController.preview.container.viewContext))
}
