//
//  SongFormView.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI
import SwiftData

struct SongFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SongFormViewModel

    init(song: Song? = nil, reviewService: any SongReviewGenerating = FoundationModelsReviewService()) {
        _viewModel = State(initialValue: SongFormViewModel(song: song, reviewService: reviewService))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Canción") {
                    TextField("Título", text: $viewModel.title)
                    TextField("Álbum", text: $viewModel.album)
                }

                Section("¿Cómo te hizo sentir?") {
                    TextField("Escribe lo que sentiste al escucharla…", text: $viewModel.feelings, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section {
                    Button {
                        Task { await viewModel.generateReview() }
                    } label: {
                        if viewModel.isGeneratingReview {
                            HStack {
                                ProgressView()
                                Text("Calificando…")
                            }
                        } else {
                            Label("Calificar con IA", systemImage: "sparkles")
                        }
                    }
                    .disabled(!viewModel.canGenerateReview)

                    if let aiSummary = viewModel.aiSummary {
                        Text(aiSummary)
                            .font(.callout)
                            .italic()
                    }
                } header: {
                    Text("Reseña con IA")
                } footer: {
                    Text(viewModel.reviewUnavailableReason
                         ?? "La IA llena las estrellas y resume tu reseña. Puedes ajustarlas antes de guardar.")
                }

                Section("Calificación") {
                    StarRatingPicker(title: "Beat", systemImage: "headphones", rating: $viewModel.beatScore)
                    StarRatingPicker(title: "Letra", systemImage: "text.quote", rating: $viewModel.lyricsScore)
                    StarRatingPicker(title: "General", systemImage: "star.circle", rating: $viewModel.overallScore)
                }
            }
            .animation(.default, value: viewModel.aiSummary)
            .navigationTitle(viewModel.isEditing ? "Editar canción" : "Nueva canción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if viewModel.save(in: modelContext) {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Algo salió mal", isPresented: $viewModel.isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview("Nueva") {
    SongFormView()
        .modelContainer(for: Song.self, inMemory: true)
}
