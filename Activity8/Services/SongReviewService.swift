//
//  SongReviewService.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import FoundationModels

protocol SongReviewGenerating {
    var unavailableReason: String? { get }
    func generateReview(title: String, album: String, feelings: String) async throws -> SongReview
}

struct FoundationModelsReviewService: SongReviewGenerating {
    private let model = SystemLanguageModel.default

    private let instructions = """
        Eres un crítico musical experto en Álvaro Díaz y el reguetón y trap de Puerto Rico.
        El usuario te dirá cómo se sintió al escuchar una canción.
        Basándote solo en lo que el usuario escribió, califica el beat, la letra y la canción en general de 1 a 5,
        y resume su reseña en español, en primera persona, como si el usuario la hubiera escrito.
        """

    var unavailableReason: String? {
        switch model.availability {
        case .available:
            nil
        case .unavailable(.deviceNotEligible):
            "Este dispositivo no es compatible con Apple Intelligence."
        case .unavailable(.appleIntelligenceNotEnabled):
            "Activa Apple Intelligence en Configuración para calificar con IA."
        case .unavailable(.modelNotReady):
            "El modelo de IA se está descargando. Intenta más tarde."
        case .unavailable:
            "Apple Intelligence no está disponible en este momento."
        }
    }

    func generateReview(title: String, album: String, feelings: String) async throws -> SongReview {
        guard unavailableReason == nil else { throw SongError.aiUnavailable }

        let session = LanguageModelSession(instructions: instructions)
        let prompt = """
            Canción: \(title)
            Álbum: \(album)
            Cómo me hizo sentir: \(feelings)
            """

        do {
            return try await session.respond(to: prompt, generating: SongReview.self).content
        } catch LanguageModelError.guardrailViolation, LanguageModelError.refusal {
            throw SongError.aiBlocked
        } catch {
            throw SongError.aiFailed
        }
    }
}
