//
//  TravelBuddySnapshotUITests.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/1/25.
//


import XCTest

final class TravelBuddySnapshotUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        Snapshot.setup(app)

        // Насильно выбираем языки/локали, если snapshot их передал
        // fastlane snapshot сам выставляет AppleLanguages/AppleLocale
        app.launch()
    }

    func testSnapshot_Onboarding_List_Map_Settings() {
        // --- Onboarding ---
        // Скрин 1: Welcome / Добро пожаловать
        Snapshot.take("01-Onboarding-Page1")
        // Next →
        tapIfExists(app.buttons["Next"])
        tapIfExists(app.buttons["Get Started"])
        // если сразу Get Started — тоже ок
        if app.buttons["Get Started"].exists { app.buttons["Get Started"].tap() }

        // --- Main Tabs ---
        // По умолчанию открывается Places (если у тебя иначе — скорректируй)
        XCTAssertTrue(app.navigationBars["Places"].exists || app.navigationBars["Места"].exists)
        Snapshot.take("02-Places-List")

        // Открыть любую ячейку (если есть)
        if app.tables.firstMatch.cells.count > 0 {
            app.tables.firstMatch.cells.element(boundBy: 0).tap()
            Snapshot.take("03-POI-Detail")
            // Закрыть деталь, если есть кнопка «x»
            let close = app.buttons["xmark.circle.fill"]
            if close.exists { close.tap() }
        }

        // Переключиться на вкладку Map
        tapTab(labelEn: "Map", labelRu: "Карта")
        // Подождём карту
        sleep(1)
        Snapshot.take("04-Map")

        // Переключиться на Settings
        tapTab(labelEn: "Settings", labelRu: "Настройки")
        Snapshot.take("05-Settings")
    }

    // MARK: - Helpers

    private func tapIfExists(_ el: XCUIElement, timeout: TimeInterval = 0.2) {
        if el.waitForExistence(timeout: timeout) { el.tap() }
    }

    private func tapTab(labelEn: String, labelRu: String) {
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons[labelEn].exists {
            tabBar.buttons[labelEn].tap()
        } else if tabBar.buttons[labelRu].exists {
            tabBar.buttons[labelRu].tap()
        } else {
            // fallback — по индексу
            tabBar.buttons.element(boundBy: 1).tap()
        }
    }
}
