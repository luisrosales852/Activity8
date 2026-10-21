//
//  SongFormViewModel.swift
//  Activity8
//
//  Created by Luis on 21/10/26.
//

import Foundation
import SwiftData

@Observable
final class SongFormViewModel {
    var title: String
    var album: String
    var feelings: String
    var beatScore: Int
    var lyricsScore: Int
    var overallScore: Int
    var aiSummary: String?

    var isGeneratingReview = false
    var errorMessage = ""
    var isShowingError = false

    private let song: Song?
    private let reviewService: any SongReviewGenerating

    init(song: Song? = nil, reviewService: any SongReviewGenerating = FoundationModelsReviewService()) {
        self.song = song
        self.reviewService = reviewService
        title = song?.title ?? ""
        album = song?.album ?? ""
        feelings = song?.feelings ?? ""
        beatScore = song?.beatScore ?? 3
        lyricsScore = song?.lyricsScore ?? 3
        overallScore = song?.overallScore ?? 3
        aiSummary = song?.aiSummary
    }

    var isEditing: Bool { song != nil }

    var reviewUnavailableReason: String? { reviewService.unavailableReason }

    var canGenerateReview: Bool {
        reviewUnavailableReason == nil
            && !isGeneratingReview
            && !feelings.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Returns `true` when the song was saved, so the view knows it can dismiss.
    func save(in modelContext: ModelContext) -> Bool {
        do {
            try SongValidator.validate(
                title: title,
                album: album,
                feelings: feelings,
                beatScore: beatScore,
                lyricsScore: lyricsScore,
                overallScore: overallScore
            )
            applyChanges(in: modelContext)
            try modelContext.save()
            return true
        } catch let error as SongError {
            showError(error)
        } catch {
            modelContext.rollback()
            showError(.saveFailed)
        }
        return false
    }

    func generateReview() async {
        isGeneratingReview = true
        defer { isGeneratingReview = false }

        do {
            let review = try await reviewService.generateReview(title: title, album: album, feelings: feelings)
            beatScore = review.beatScore
            lyricsScore = review.lyricsScore
            overallScore = review.overallScore
            aiSummary = review.summary
        } catch let error as SongError {
            showError(error)
        } catch {
            showError(.aiFailed)
        }
    }

    private func applyChanges(in modelContext: ModelContext) {
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
