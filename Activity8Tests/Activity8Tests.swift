//
//  Activity8Tests.swift
//  Activity8Tests
//
//  Created by Luis on 21/10/26.
//

import Testing
import SwiftData
@testable import Activity8

@MainActor
struct Activity8Tests {

    @Test func blankTitleThrowsEmptyTitleError() {
        #expect(throws: SongError.emptyTitle) {
            try SongValidator.validate(
                title: "   ",
                album: "Sayonara",
                feelings: "El beat está brutal.",
                beatScore: 3,
                lyricsScore: 3,
                overallScore: 3
            )
        }
    }

    @Test func savingNewSongInsertsItIntoSwiftData() throws {
        let container = try ModelContainer(
            for: Song.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let viewModel = SongFormViewModel(reviewService: MockReviewService())
        viewModel.title = "  Gasolina de Avión  "
        viewModel.album = "Sayonara"
        viewModel.feelings = "El beat está brutal."
        viewModel.overallScore = 5

        let didSave = viewModel.save(in: context)

        let songs = try context.fetch(FetchDescriptor<Song>())
        let savedSong = try #require(songs.first)
        #expect(didSave)
        #expect(songs.count == 1)
        #expect(savedSong.title == "Gasolina de Avión")
        #expect(savedSong.overallScore == 5)
        #expect(!viewModel.isShowingError)
    }

}

@MainActor
private struct MockReviewService: SongReviewGenerating {
    var unavailableReason: String? = nil

    func generateReview(title: String, album: String, feelings: String) async throws -> SongReview {
        SongReview(beatScore: 5, lyricsScore: 4, overallScore: 5, summary: "Reseña de prueba.")
    }
}
