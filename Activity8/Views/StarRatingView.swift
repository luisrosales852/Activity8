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
    var onSelect: ((Int) -> Void)? = nil

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maximum, id: \.self) { star in
                if let onSelect {
                    Button {
                        onSelect(star)
                    } label: {
                        starImage(for: star)
                    }
                    .buttonStyle(.borderless)
                } else {
                    starImage(for: star)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(rating) de \(maximum) estrellas")
    }

    private func starImage(for star: Int) -> some View {
        Image(systemName: star <= rating ? "star.fill" : "star")
            .foregroundStyle(star <= rating ? Color.yellow : Color.secondary)
    }
}

#Preview {
    StarRatingView(rating: 4)
}
