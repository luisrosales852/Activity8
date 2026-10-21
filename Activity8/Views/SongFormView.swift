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

    @State private var title: String
    @State private var album: String
    @State private var feelings: String
    @State private var beatScore: Int
    @State private var lyricsScore: Int
    @State private var overallScore: Int

    @State private var errorMessage = ""
    @State private var isShowingError = false

    init(song: Song? = nil) {
        self.song = song
        _title = State(initialValue: song?.title ?? "")
        _album = State(initialValue: song?.album ?? "")
        _feelings = State(initialValue: song?.feelings ?? "")
        _beatScore = State(initialValue: song?.beatScore ?? 3)
        _lyricsScore = State(initialValue: song?.lyricsScore ?? 3)
        _overallScore = State(initialValue: song?.overallScore ?? 3)
    }

    private var isEditing: Bool { song != nil }

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
            .alert("No se pudo guardar", isPresented: $isShowingError) {
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
        } else {
            let newSong = Song(
                title: cleanTitle,
                album: cleanAlbum,
                feelings: cleanFeelings,
                beatScore: beatScore,
                lyricsScore: lyricsScore,
                overallScore: overallScore
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
