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

    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    ContentUnavailableView(
                        "Aún no has calificado canciones",
                        systemImage: "music.note.list",
                        description: Text("Agrega tu primera canción de Álvaro Díaz para empezar tu ranking.")
                    )
                } else {
                    List(songs) { song in
                        SongRowView(song: song)
                    }
                }
            }
            .navigationTitle("Mi Ranking")
        }
    }
}

#Preview {
    SongListView()
        .modelContainer(for: Song.self, inMemory: true)
}
