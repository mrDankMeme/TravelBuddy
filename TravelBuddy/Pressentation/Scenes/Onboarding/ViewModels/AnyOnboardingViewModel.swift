//
//  AnyOnboardingViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//

import Combine

/// Универсальный Any-ViewModel для Onboarding, скрывает конкретный тип
public final class AnyOnboardingViewModel: OnboardingViewModelProtocol {
    // MARK: — ObservableObject conformance
    public let objectWillChange = ObservableObjectPublisher()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: — Outputs
    @Published public private(set) var pages: [OnboardingPage]
    @Published public private(set) var currentPage: Int
    @Published public private(set) var hasCompletedOnboarding: Bool
    
    
    // MARK: — Wrapped instance
    private let wrapped: any OnboardingViewModelProtocol
    
    /// Инициализируем тип-стирающую «обёртку»
    public init(_ wrapped: any OnboardingViewModelProtocol) {
        self.wrapped = wrapped
        // копируем начальные значения
        self.pages               = wrapped.pages
        self.currentPage         = wrapped.currentPage
        self.hasCompletedOnboarding = wrapped.hasCompletedOnboarding
        
        // подписываемся на objectWillChange wrapped-VM,
        // чтобы передавать события субъективного обновления и синхронизировать свойства
        wrapped.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.pages               = self.wrapped.pages
                self.currentPage         = self.wrapped.currentPage
                self.hasCompletedOnboarding = self.wrapped.hasCompletedOnboarding
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: — Inputs: просто делегируем вызовы
    public func next() {
        wrapped.next()
    }
    public func previous() {
        wrapped.previous()
    }
    public func skip() {
        wrapped.skip()
    }
}
