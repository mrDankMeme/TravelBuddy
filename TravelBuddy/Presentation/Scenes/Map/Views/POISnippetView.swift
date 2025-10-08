//
//  POISnippetView.swift
//  TravelBuddy
//

import SwiftUI
import MapKit

struct POISnippetView: View {
    let poi: POI
    var onDetails: () -> Void
    var onRoute:   () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12.scale) {

            // MARK: - Верхняя часть: текст + миниатюра
            HStack(alignment: .top, spacing: 12.scale) {

                // Левая колонка — текст, ограниченный шириной до картинки
                VStack(alignment: .leading, spacing: 4.scale) {
                    Text(poi.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    if let cat = poi.category {
                        Text(cat)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let desc = poi.description {
                        Text(desc)
                            .font(.body)
                            .lineLimit(3)
                            .foregroundColor(.primary)
                    }
                }

                Spacer(minLength: 0) // чуть сжимает текст, не даёт вылезти под картинку

                // Справа миниатюра
                if let path = poi.imageURL?.path {
                    POIImageView(imagePath: path)
                        .frame(width: 96.scale, height: 72.scale)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8.scale))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.scale)
                                .stroke(Color(.separator), lineWidth: 0.5)
                        )
                }
            }

            // MARK: - Кнопки действий
            HStack {
                Button(L10n.snippetDetails, action: onDetails)
                    .buttonStyle(.borderedProminent)

                Spacer()

                Button(L10n.detailOpenInMaps, action: onRoute)
            }
        }
        .padding(16.scale)
        .background(
            RoundedRectangle(cornerRadius: 12.scale)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 4.scale, x: 0, y: 2.scale)
        )
        .padding(.horizontal, 16.scale)
        .padding(.top, 8.scale)
    }
}
