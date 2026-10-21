//
//  SongListView.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI
import SwiftData

struct SongListView: View {
    @Query(sort: [
        SortDescriptor(\Song.overallScore, order: .reverse),
        SortDescriptor(\Song.dateAdded, order: .reverse)
    ])
    private var songs: [Song]

    @State private var isShowingAddForm = false
    @State private var songToEdit: Song?

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
        }
    }
}

#Preview {
    SongListView()
        .modelContainer(for: Song.self, inMemory: true)
}
