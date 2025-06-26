//
//  OnboardingView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//

import SwiftUI

public struct OnboardingView<VM: OnboardingViewModelProtocol>: View {
    @ObservedObject private var vm: VM
    @Namespace    private var imageNamespace
    
    public init(vm: VM) {
        self.vm = vm
    }
    
    public var body: some View {
      ZStack {
        Color(DesignTokens.colorBackground)
          .ignoresSafeArea()

        VStack(spacing: DesignTokens.spacingMedium) {
          Spacer()

          // картинка
            ForEach(vm.pages, id: \.id) { page in
                if page.id == vm.currentPage {
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300.scale)
                        .padding(.horizontal, DesignTokens.spacingMedium)
                        .transition(
                            .asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            )
                        )
                }
            }

          Text(vm.pages[vm.currentPage].title)
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.spacingMedium)

          Text(vm.pages[vm.currentPage].description)
            .font(.body)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.spacingMedium)

          Spacer()

          HStack(spacing: 5.scale) {
            ForEach(vm.pages.indices, id: \.self) { idx in
              Circle()
                .fill(idx == vm.currentPage
                      ? Color(DesignTokens.colorPrimary)
                      : Color.gray.opacity(0.4))
                .frame(width: 5.scale, height: 5.scale)
                .scaleEffect(idx == vm.currentPage ? 1.2 : 1.0)
            }
          }

          HStack {
            if vm.currentPage > 0 {
              Button("Back") {
                withAnimation(.easeInOut) {
                  vm.previous()
                }
              }
              .font(.body)
              .padding(.trailing, DesignTokens.spacingMedium)
            }

            Spacer()

            Button(vm.currentPage == vm.pages.count - 1 ? "Get Started" : "Next") {
              withAnimation(.easeInOut) {
                vm.next()
                
              }
            }
            .font(.body)
          }
          .padding(.horizontal, DesignTokens.spacingMedium)
        }
        .foregroundColor(.primary)
      }
      // анимация на уровень выше
      .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.currentPage)
    }

}
