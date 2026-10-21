//
//  SongReview.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import FoundationModels

@Generable
struct SongReview {
    @Guide(description: "Calificación del beat y la producción, de 1 a 5", .range(1...5))
    let beatScore: Int

    @Guide(description: "Calificación de la letra, de 1 a 5", .range(1...5))
    let lyricsScore: Int

    @Guide(description: "Calificación general de la canción, de 1 a 5", .range(1...5))
    let overallScore: Int

    @Guide(description: "Resumen de la reseña en español, en primera persona, máximo dos oraciones")
    let summary: String
}
