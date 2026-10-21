//
//  SongListView.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI
import SwiftData

struct SongListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [
        SortDescriptor(\Song.overallScore, order: .reverse),
        SortDescriptor(\Song.dateAdded, order: .reverse)
    ])
    private var songs: [Song]

    @State private var isShowingAddForm = false
    @State private var songToEdit: Song?
    @State private var songToDelete: Song?
    @State private var isShowingDeleteConfirmation = false

    @State private var errorMessage = ""
    @State private var isShowingError = false

    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    ContentUnavailableView {
                        Label("Aún no has calificado canciones", systemImage: "music.note.list")
                    } description: {
                        Text("Agrega tu primera canción de Álvaro Díaz para empezar tu ranking.")
                    } actions: {
                        Button("Agregar canción") { isShowingAddForm = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(songs) { song in
                        Button {
                            songToEdit = song
                        } label: {
                            SongRowView(song: song)
                        }
                        .foregroundStyle(.primary)
                        .swipeActions(edge: .trailing) {
                            Button("Eliminar", systemImage: "trash") {
                                songToDelete = song
                                isShowingDeleteConfirmation = true
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .navigationTitle("Mi Ranking")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Agregar canción", systemImage: "plus") {
                        isShowingAddForm = true
                    }
                }
            }
            .sheet(isPresented: $isShowingAddForm) {
                SongFormView()
            }
            .sheet(item: $songToEdit) { song in
                SongFormView(song: song)
            }
            .confirmationDialog(
                "¿Eliminar «\(songToDelete?.title ?? "")»?",
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible,
                presenting: songToDelete
            ) { song in
                Button("Eliminar", role: .destructive) { delete(song) }
                Button("Cancelar", role: .cancel) {}
            } message: { _ in
                Text("Esta acción no se puede deshacer.")
            }
            .alert("Ocurrió un error", isPresented: $isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func delete(_ song: Song) {
        modelContext.delete(song)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = SongError.deleteFailed.localizedDescription
            isShowingError = true
        }
    }
}

#Preview {
    SongListView()
        .modelContainer(for: Song.self, inMemory: true)
}
