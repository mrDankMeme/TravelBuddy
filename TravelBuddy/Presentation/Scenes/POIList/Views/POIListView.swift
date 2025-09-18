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
        ZStack {
            content
            if viewModel.isLoading {
                // Полноэкранный индикатор, когда пусто
                if viewModel.pois.isEmpty {
                    ProgressView().scaleEffect(1.2)
                } else {
                    // Компактный индикатор поверх уже показанного списка
                    VStack { Spacer() }
                        .overlay(
                            ProgressView()
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.bottom, 24),
                            alignment: .bottom
                        )
                }
            }
        }
        .navigationTitle("Places")
        .onAppear { viewModel.fetchPOIs() }
    }
    
    @ViewBuilder
    private var content: some View {
        if let err = viewModel.errorMessage {
            VStack(spacing: 16) {
                Text("Error: \(err)").multilineTextAlignment(.center)
                Button("Retry") { viewModel.fetchPOIs() }
            }
            .padding()
        } else {
            VStack {
                Picker("Category", selection: $viewModel.filter) {
                    ForEach(POICategoryFilter.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.vertical)
                
                List(viewModel.pois) { poi in
                    Button { router.goDetail(poi) } label: {
                        HStack {
                            POIImageView(imagePath: poi.imageURL?.path)
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.trailing, 4)
                            VStack(alignment: .leading) {
                                Text(poi.name).font(.headline)
                                if let c = poi.category {
                                    Text(c).font(.subheadline).foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
