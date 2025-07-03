//
//  POIListView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//

import SwiftUI

public struct POIListView: View {
    @StateObject private var vm: AnyPOIListViewModel

    public init(viewModel: AnyPOIListViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let err = vm.errorMessage {
                    VStack(spacing: 16) {
                        Text("Error: \(err)").multilineTextAlignment(.center)
                        Button("Retry") { vm.fetchPOIs() }
                    }
                    .padding()
                } else {
                    List {
                        Picker("Category", selection: $vm.filter) {
                            ForEach(POICategoryFilter.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical)

                        ForEach(vm.pois) { poi in
                            NavigationLink(destination: POIDetailView(poi: poi, viewModel: vm)) {
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
                    }
                }
            }
            .navigationTitle("Places")
        }
        .onAppear { vm.fetchPOIs() }
    }
}
