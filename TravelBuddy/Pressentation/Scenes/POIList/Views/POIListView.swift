//
//  POIListView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//


import SwiftUI

public struct POIListView: View {
    @ObservedObject var viewModel: AnyPOIListViewModel
    @EnvironmentObject var router: POIListRouter

    public init(viewModel: AnyPOIListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let err = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error: \(err)")
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.fetchPOIs()
                    }
                }
                .padding()
            } else {
                // Сегментированный фильтр
                Picker("Category", selection: $viewModel.filter) {
                    ForEach(POICategoryFilter.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)

                // Список с кнопками вместо NavigationLink
                List(viewModel.pois) { poi in
                    Button {
                        router.goDetail(poi)
                    } label: {
                        HStack {
                            POIImageView(imagePath: poi.imageURL?.path)
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.trailing, 4)

                            VStack(alignment: .leading) {
                                Text(poi.name)
                                    .font(.headline)
                                if let c = poi.category {
                                    Text(c)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Places")
        .onAppear {
            viewModel.fetchPOIs()
        }
    }
}
