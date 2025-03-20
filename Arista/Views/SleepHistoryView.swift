//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct SleepHistoryView: View {
    @ObservedObject var viewModel: SleepViewModel
    @State private var showingAddSleepView = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.sleepSessions.isEmpty {
                    NoSleepSessionsView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.sleepSessions) { session in
                        SleepSessionRow(session: session)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }
                    .onDelete(perform: deleteSleep)
                }
            }
            .navigationTitle("Historique de Sommeil")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSleepView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSleepView) {
                AddSleepView(viewModel: viewModel)
            }
        }
    }
    
    func deleteSleep(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }

        let sleepToDelete = viewModel.sleepSessions[index]
        viewModel.deleteSleep(sleep: sleepToDelete)
    }
}

// MARK: - SleepSessionRow View

struct SleepSessionRow: View {
    let session: SleepData

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)

            HStack {
                QualityIndicator(quality: Int64(session.quality))
                    .padding(.leading)

                VStack(alignment: .leading) {
                    Text("Début : \(session.startDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Durée : \(session.duration / 60) heures")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - QualityIndicator View

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
                .font(.caption)
        }
    }

    func qualityColor(_ quality: Int) -> Color {
        switch (10 - Int(quality)) {
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

// MARK: - NoSleepSessionsView

struct NoSleepSessionsView: View {
    var body: some View {
        VStack {
            Image(systemName: "moon.zzz")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()

            Text("No sleep sessions yet!")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(.bottom)

            Text("Track your sleep to see your sleep history.")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .padding()
    }
}
#Preview {
    SleepHistoryView(viewModel: SleepViewModel(modelService: PreviewHelpers.previewModelService))
}
