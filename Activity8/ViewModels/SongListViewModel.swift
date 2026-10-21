//
//  SongListViewModel.swift
//  Activity8
//
//  Created by Luis on 21/10/26.
//

import Foundation
import SwiftData

@Observable
final class SongListViewModel {
    var isShowingAddForm = false
    var songToEdit: Song?
    var songToDelete: Song?
    var isShowingDeleteConfirmation = false

    var errorMessage = ""
    var isShowingError = false

    func confirmDelete(_ song: Song) {
        songToDelete = song
        isShowingDeleteConfirmation = true
    }

    func delete(_ song: Song, from modelContext: ModelContext) {
        modelContext.delete(song)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showError(.deleteFailed)
        }
    }

    private func showError(_ error: SongError) {
        errorMessage = error.localizedDescription
        isShowingError = true
    }
}
