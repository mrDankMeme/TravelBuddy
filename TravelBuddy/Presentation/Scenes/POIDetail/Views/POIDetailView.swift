//
//  POIDetailView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import SwiftUI
import MapKit

public struct POIDetailView: View {
  @ObservedObject private var vm: POIDetailViewModel
  @Binding private var sheetRoute: POIDetailRoute?

  public init(
    viewModel: POIDetailViewModel,
    sheetRoute: Binding<POIDetailRoute?>
  ) {
    self.vm = viewModel
    self._sheetRoute = sheetRoute
  }

  public var body: some View {
    VStack(spacing: 16) {
      HStack { Spacer()
        Button(action: vm.didTapClose) {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
        }
      }

      Text(vm.model.poi.name).font(.largeTitle)

      if vm.isLoadingAddress {
        ProgressView(L10n.detailLoadingAddress)
      } else if let addr = vm.address {
        Text(addr).italic()
      } else if let err = vm.errorMessage {
        // Экранная подсветка + route-алерт прилетит из координатора
        Text(err).foregroundColor(.red)
      }

      Button(L10n.detailShare,        action: vm.didTapShare)
      Button(L10n.detailOpenInMaps,   action: vm.didTapOpenInMaps)
      Spacer()
    }
    .padding()
    .onAppear(perform: vm.onAppear)
    .navigationTitle(vm.model.poi.name)
    .sheet(item: $sheetRoute) { route in
      switch route {
      case .share(let url):
        ActivityViewController(activityItems: [url])
      default:
        EmptyView()
      }
    }
  }
}


// UIKit wrapper
struct ActivityViewController: UIViewControllerRepresentable {
  let activityItems: [Any]

  func makeUIViewController(
    context: Context
  ) -> UIActivityViewController {
    UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: nil
    )
  }

  func updateUIViewController(
    _ vc: UIActivityViewController,
    context: Context
  ) {}
}
