//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CoreData

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @State private var showingAddExerciseView = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.exercises.isEmpty {
                    NoExercisesView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }
                    .onDelete(perform: deleteExercise)
                }
            }
            .navigationTitle("Exercices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExerciseView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                viewModel.reload()
            }
            .sheet(isPresented: $showingAddExerciseView) {
                AddExerciseView(viewModel: AddExerciseViewModel(context: viewModel.viewContext))
            }
        }
    }

    func iconForCategory(_ category: String) -> String {
        switch category {
            case "Football":
                return "sportscourt"
            case "Natation":
                return "waveform.path.ecg"
            case "Running":
                return "figure.run"
            case "Marche":
                return "figure.walk"
            case "Cyclisme":
                return "bicycle"
            default:
                return "questionmark"
        }
    }

    func deleteExercise(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }

        let exerciseToDelete = viewModel.exercises[index]
        viewModel.deleteExercise(exercise: exerciseToDelete)
    }
}
// MARK: - ExerciseRow View
struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)

            HStack {
                Image(systemName: iconForCategory(exercise.category ?? "football"))
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(.leading)

                VStack(alignment: .leading) {
                    Text(exercise.category ?? "undefined category")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Durée: \(exercise.duration) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(exercise.startDate?.formatted(date: .abbreviated, time: .shortened) ?? "Date non définie")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)

                Spacer()

                IntensityIndicator(intensity: exercise.intensity)
                    .padding(.trailing)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .padding(.vertical, 4)
    }

    func iconForCategory(_ category: String) -> String {
        switch category {
            case "Football":
                return "sportscourt"
            case "Natation":
                return "waveform.path.ecg"
            case "Running":
                return "figure.run"
            case "Marche":
                return "figure.walk"
            case "Cyclisme":
                return "bicycle"
            default:
                return "questionmark"
        }
    }
}

// MARK: - IntensityIndicator View
struct IntensityIndicator: View {
    var intensity: Int64

    var body: some View {
        Circle()
            .fill(colorForIntensity(Int(intensity)))
            .frame(width: 12, height: 12)
            .shadow(radius: 1)
    }

    func colorForIntensity(_ intensity: Int) -> Color {
        switch intensity {
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

// MARK: - No Exercises View
struct NoExercisesView: View {
    var body: some View {
        VStack {
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()

            Text("Soyez actifs!")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(.bottom)

            Text("Ajoutez votre première séance...")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    ExerciseListView(viewModel: ExerciseListViewModel(context: PersistenceController.preview.container.viewContext))
}
