//
//  StarRatingView.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Int
    var maximum = SongValidator.scoreRange.upperBound

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maximum, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? Color.yellow : Color.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(rating) de \(maximum) estrellas")
    }
}

#Preview {
    StarRatingView(rating: 4)
}
