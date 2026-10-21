//
//  Song.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import Foundation
import SwiftData

@Model
final class Song {
    var title: String
    var album: String
    var feelings: String
    var beatScore: Int
    var lyricsScore: Int
    var overallScore: Int
    var aiSummary: String?
    var dateAdded: Date

    init(
        title: String,
        album: String,
        feelings: String,
        beatScore: Int = 3,
        lyricsScore: Int = 3,
        overallScore: Int = 3,
        aiSummary: String? = nil,
        dateAdded: Date = .now
    ) {
        self.title = title
        self.album = album
        self.feelings = feelings
        self.beatScore = beatScore
        self.lyricsScore = lyricsScore
        self.overallScore = overallScore
        self.aiSummary = aiSummary
        self.dateAdded = dateAdded
    }
}
