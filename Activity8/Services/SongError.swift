//
//  SongError.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import Foundation

enum SongError: LocalizedError, Equatable {
    case emptyTitle
    case emptyAlbum
    case emptyFeelings
    case invalidScore
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            "Escribe el título de la canción."
        case .emptyAlbum:
            "Escribe el álbum de la canción."
        case .emptyFeelings:
            "Cuéntanos cómo te hizo sentir la canción."
        case .invalidScore:
            "Las calificaciones deben estar entre 1 y 5 estrellas."
        case .saveFailed:
            "No se pudo guardar la canción. Intenta de nuevo."
        case .deleteFailed:
            "No se pudo eliminar la canción. Intenta de nuevo."
        }
    }
}
