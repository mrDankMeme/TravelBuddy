//
//  OnboardingViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//


import Combine

public protocol OnboardingViewModelProtocol: ObservableObject {
    /// Чтобы View могла подписаться на любые изменения
    var objectWillChange: ObservableObjectPublisher { get }
    
    // MARK: — Outputs
    var pages: [OnboardingPage] { get }
    var currentPage: Int { get }
    var hasCompletedOnboarding: Bool { get }
    
    // MARK: — Inputs
    func next()
    func previous()
    func skip()
}

public final class OnboardingViewModel: OnboardingViewModelProtocol {
    // MARK: — ObservableObject conformance
    public let objectWillChange = ObservableObjectPublisher()
    
    // MARK: — Outputs
    @Published public private(set) var currentPage: Int = 0
    @Published public private(set) var hasCompletedOnboarding: Bool = false
    
    public let pages: [OnboardingPage]
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        // Страницы онбординга
        self.pages = [
            OnboardingPage(
                id: 0,
                imageName: "onb1",
                title: "Welcome to TravelBuddy",
                description: "Discover new places and plan your journeys with ease."
            ),
            OnboardingPage(
                id: 1,
                imageName: "onb2",
                title: "Track Your Route",
                description: "Use our interactive map to mark and save your favorite spots."
            ),
            OnboardingPage(
                id: 2,
                imageName: "onb3",
                title: "Stay Notified",
                description: "Get reminders about upcoming trips and special offers."
            )
        ]
    }
    
    // MARK: — Inputs
    
    public func next() {
        guard currentPage < pages.count - 1 else {
            skip()
            return
        }
        currentPage += 1
        objectWillChange.send()                 // <-- уведомляем SwiftUI заранее
    }
    
    public func previous() {
        guard currentPage > 0 else { return }
        currentPage -= 1
        objectWillChange.send()
    }
    
    public func skip() {
        hasCompletedOnboarding = true
        objectWillChange.send()
    }
}
