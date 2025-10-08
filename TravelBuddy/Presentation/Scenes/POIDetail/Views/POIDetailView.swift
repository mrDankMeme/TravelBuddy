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
    ScrollView {
      VStack(spacing: 16) {

        // Hero-image (локальные картинки из бандла уже читаются POIImageView)
        POIImageView(imagePath: vm.model.poi.imageURL?.path)
          .frame(height: 220)
          .frame(maxWidth: .infinity)
          .clipped()
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color(.separator), lineWidth: 0.5)
          )
          .padding(.top, 8)

        // Заголовок
        Text(vm.model.poi.name)
          .font(.title.bold())
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity, alignment: .center)

        // Адрес / загрузка / ошибка
        Group {
          if vm.isLoadingAddress {
            ProgressView(L10n.detailLoadingAddress)
          } else if let addr = vm.address {
            Text(addr).italic().multilineTextAlignment(.center)
          } else if let err = vm.errorMessage {
            Text(err).foregroundColor(.red).multilineTextAlignment(.center)
          }
        }
        .padding(.horizontal)

        // Действия
        VStack(spacing: 12) {
          Button(L10n.detailShare) { vm.didTapShare() }
            .buttonStyle(.borderedProminent)

          Button(L10n.detailOpenInMaps) { vm.didTapOpenInMaps() }
        }
        .padding(.top, 8)

        Spacer(minLength: 8)
      }
      .padding(.horizontal)
      .onAppear(perform: vm.onAppear)
    }
    // Навбар и системный back — push-навигация решает закрытие экрана
    .navigationTitle(vm.model.poi.name)
    .navigationBarTitleDisplayMode(.inline)

    // Лист для share (через координатор)
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

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
  }

  func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
