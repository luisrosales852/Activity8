//
//  SongValidator.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import Foundation

enum SongValidator {
    static let scoreRange = 1...5

    static func validate(
        title: String,
        album: String,
        feelings: String,
        beatScore: Int,
        lyricsScore: Int,
        overallScore: Int
    ) throws {
        guard !isBlank(title) else { throw SongError.emptyTitle }
        guard !isBlank(album) else { throw SongError.emptyAlbum }
        guard !isBlank(feelings) else { throw SongError.emptyFeelings }

        let scores = [beatScore, lyricsScore, overallScore]
        guard scores.allSatisfy(scoreRange.contains) else { throw SongError.invalidScore }
    }

    private static func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
