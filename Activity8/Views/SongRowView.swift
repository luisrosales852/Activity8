//
//  SongRowView.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI

struct SongRowView: View {
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.title)
                .font(.headline)
            Text(song.album)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            StarRatingView(rating: song.overallScore)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        SongRowView(song: Song(
            title: "Gasolina de Avión",
            album: "Sayonara",
            feelings: "El beat está brutal.",
            overallScore: 5
        ))
    }
}
