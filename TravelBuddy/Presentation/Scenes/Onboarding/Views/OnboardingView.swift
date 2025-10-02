//
//  OnboardingView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//

import SwiftUI

public struct OnboardingView<VM: OnboardingViewModelProtocol>: View {
    @ObservedObject private var vm: VM

    public init(vm: VM) { self.vm = vm }

    public var body: some View {
        ZStack {
            Color(DesignTokens.colorBackground).ignoresSafeArea()

            VStack(spacing: DesignTokens.spacingMedium) {
                Spacer()

                // Картинка текущей страницы (простая анимация)
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

                // Пейдж-индикатор
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

                // Кнопки
                HStack {
                    if vm.currentPage > 0 {
                        Button(L10n.onbBack) {
                            withAnimation(.easeInOut) { vm.previous() }
                        }
                        .font(.body)
                        .accessibilityIdentifier("onboarding.back")
                        .padding(.trailing, DesignTokens.spacingMedium)
                    }

                    Spacer()

                    Button(vm.currentPage == vm.pages.count - 1 ? L10n.onbGetStarted : L10n.onbNext) {
                        withAnimation(.easeInOut) { vm.next() }
                    }
                    .font(.body)
                    .accessibilityIdentifier(
                        vm.currentPage == vm.pages.count - 1
                        ? "onboarding.get_started" : "onboarding.next"
                    )
                }
                .padding(.horizontal, DesignTokens.spacingMedium)
            }
            .foregroundColor(.primary)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.currentPage)
    }
}
