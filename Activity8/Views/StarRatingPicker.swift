//
//  StarRatingPicker.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI

struct StarRatingPicker: View {
    let title: String
    let systemImage: String
    @Binding var rating: Int

    private let range = SongValidator.scoreRange

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            StarRatingView(rating: rating) { rating = $0 }
                .font(.title3)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(rating) de \(range.upperBound) estrellas")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                rating = min(rating + 1, range.upperBound)
            case .decrement:
                rating = max(rating - 1, range.lowerBound)
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    @Previewable @State var rating = 3
    Form {
        StarRatingPicker(title: "Beat", systemImage: "headphones", rating: $rating)
    }
}
