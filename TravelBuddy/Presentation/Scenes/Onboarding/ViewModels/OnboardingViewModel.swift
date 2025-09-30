//
//  OnboardingViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//


import Combine
import Foundation

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
    @Published public private(set) var hasCompletedOnboarding: Bool
    
    public let pages: [OnboardingPage]
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        // Страницы онбординга
        self.pages = [
                   OnboardingPage(id: 0, imageName: "onb1",
                                  title: L10n.onbPage1Title, description: L10n.onbPage1Desc),
                   OnboardingPage(id: 1, imageName: "onb2",
                                  title: L10n.onbPage2Title, description: L10n.onbPage2Desc),
                   OnboardingPage(id: 2, imageName: "onb3",
                                  title: L10n.onbPage3Title, description: L10n.onbPage3Desc)
               ]
        self.hasCompletedOnboarding = UserDefaults.standard.hasCompletedOnboarding
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
        UserDefaults.standard.hasCompletedOnboarding = true
        objectWillChange.send()
    }
}
