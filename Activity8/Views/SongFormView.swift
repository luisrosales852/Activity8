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

    private let song: Song?
    private let reviewService: any SongReviewGenerating

    @State private var title: String
    @State private var album: String
    @State private var feelings: String
    @State private var beatScore: Int
    @State private var lyricsScore: Int
    @State private var overallScore: Int
    @State private var aiSummary: String?

    @State private var isGeneratingReview = false
    @State private var errorMessage = ""
    @State private var isShowingError = false

    init(song: Song? = nil, reviewService: any SongReviewGenerating = FoundationModelsReviewService()) {
        self.song = song
        self.reviewService = reviewService
        _title = State(initialValue: song?.title ?? "")
        _album = State(initialValue: song?.album ?? "")
        _feelings = State(initialValue: song?.feelings ?? "")
        _beatScore = State(initialValue: song?.beatScore ?? 3)
        _lyricsScore = State(initialValue: song?.lyricsScore ?? 3)
        _overallScore = State(initialValue: song?.overallScore ?? 3)
        _aiSummary = State(initialValue: song?.aiSummary)
    }

    private var isEditing: Bool { song != nil }

    private var canGenerateReview: Bool {
        reviewService.unavailableReason == nil
            && !isGeneratingReview
            && !feelings.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Canción") {
                    TextField("Título", text: $title)
                    TextField("Álbum", text: $album)
                }

                Section("¿Cómo te hizo sentir?") {
                    TextField("Escribe lo que sentiste al escucharla…", text: $feelings, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section {
                    Button {
                        Task { await generateReview() }
                    } label: {
                        if isGeneratingReview {
                            HStack {
                                ProgressView()
                                Text("Calificando…")
                            }
                        } else {
                            Label("Calificar con IA", systemImage: "sparkles")
                        }
                    }
                    .disabled(!canGenerateReview)

                    if let aiSummary {
                        Text(aiSummary)
                            .font(.callout)
                            .italic()
                    }
                } header: {
                    Text("Reseña con IA")
                } footer: {
                    Text(reviewService.unavailableReason
                         ?? "La IA llena las estrellas y resume tu reseña. Puedes ajustarlas antes de guardar.")
                }

                Section("Calificación") {
                    StarRatingPicker(title: "Beat", systemImage: "headphones", rating: $beatScore)
                    StarRatingPicker(title: "Letra", systemImage: "text.quote", rating: $lyricsScore)
                    StarRatingPicker(title: "General", systemImage: "star.circle", rating: $overallScore)
                }
            }
            .navigationTitle(isEditing ? "Editar canción" : "Nueva canción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: save)
                }
            }
            .alert("Algo salió mal", isPresented: $isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func save() {
        do {
            try SongValidator.validate(
                title: title,
                album: album,
                feelings: feelings,
                beatScore: beatScore,
                lyricsScore: lyricsScore,
                overallScore: overallScore
            )
            applyChanges()
            try modelContext.save()
            dismiss()
        } catch let error as SongError {
            showError(error)
        } catch {
            modelContext.rollback()
            showError(.saveFailed)
        }
    }

    private func generateReview() async {
        isGeneratingReview = true
        defer { isGeneratingReview = false }

        do {
            let review = try await reviewService.generateReview(title: title, album: album, feelings: feelings)
            withAnimation {
                beatScore = review.beatScore
                lyricsScore = review.lyricsScore
                overallScore = review.overallScore
                aiSummary = review.summary
            }
        } catch let error as SongError {
            showError(error)
        } catch {
            showError(.aiFailed)
        }
    }

    private func applyChanges() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAlbum = album.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanFeelings = feelings.trimmingCharacters(in: .whitespacesAndNewlines)

        if let song {
            song.title = cleanTitle
            song.album = cleanAlbum
            song.feelings = cleanFeelings
            song.beatScore = beatScore
            song.lyricsScore = lyricsScore
            song.overallScore = overallScore
            song.aiSummary = aiSummary
        } else {
            let newSong = Song(
                title: cleanTitle,
                album: cleanAlbum,
                feelings: cleanFeelings,
                beatScore: beatScore,
                lyricsScore: lyricsScore,
                overallScore: overallScore,
                aiSummary: aiSummary
            )
            modelContext.insert(newSong)
        }
    }

    private func showError(_ error: SongError) {
        errorMessage = error.localizedDescription
        isShowingError = true
    }
}

#Preview("Nueva") {
    SongFormView()
        .modelContainer(for: Song.self, inMemory: true)
}
