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

    @State private var viewModel = SongListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    ContentUnavailableView {
                        Label("Aún no has calificado canciones", systemImage: "music.note.list")
                    } description: {
                        Text("Agrega tu primera canción de Álvaro Díaz para empezar tu ranking.")
                    } actions: {
                        Button("Agregar canción") { viewModel.isShowingAddForm = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(songs) { song in
                        Button {
                            viewModel.songToEdit = song
                        } label: {
                            SongRowView(song: song)
                        }
                        .foregroundStyle(.primary)
                        .swipeActions(edge: .trailing) {
                            Button("Eliminar", systemImage: "trash") {
                                viewModel.confirmDelete(song)
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
                        viewModel.isShowingAddForm = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddForm) {
                SongFormView()
            }
            .sheet(item: $viewModel.songToEdit) { song in
                SongFormView(song: song)
            }
            .confirmationDialog(
                "¿Eliminar «\(viewModel.songToDelete?.title ?? "")»?",
                isPresented: $viewModel.isShowingDeleteConfirmation,
                titleVisibility: .visible,
                presenting: viewModel.songToDelete
            ) { song in
                Button("Eliminar", role: .destructive) {
                    viewModel.delete(song, from: modelContext)
                }
                Button("Cancelar", role: .cancel) {}
            } message: { _ in
                Text("Esta acción no se puede deshacer.")
            }
            .alert("Ocurrió un error", isPresented: $viewModel.isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    SongListView()
        .modelContainer(for: Song.self, inMemory: true)
}
