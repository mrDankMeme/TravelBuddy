//
//  TravelBuddySnapshotUITests.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/1/25.
//

import XCTest

@MainActor
final class TravelBuddySnapshotUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()

        // init fastlane-snapshot (из SnapshotHelper.swift)
        setupSnapshot(app)

        // fastlane snapshot сам выставит AppleLanguages/AppleLocale
        app.launch()
    }

    func testSnapshot_Onboarding_List_Map_Settings() {
        // --- Onboarding ---
        snapshot("01-Onboarding-Page1")

        // двигаем онбординг по стабильным идентификаторам (язык-агностично)
        tapIfExists(app.buttons["onboarding.next"], timeout: 1.0)         // p1 -> p2
        tapIfExists(app.buttons["onboarding.next"], timeout: 1.0)         // p2 -> p3
        tapIfExists(app.buttons["onboarding.get_started"], timeout: 1.0)  // finish

        // fallback на старые текстовые локаторы (на случай локального прогона)
        if app.buttons["Next"].exists { app.buttons["Next"].tap() }
        if app.buttons["Next"].exists { app.buttons["Next"].tap() }
        if app.buttons["Get Started"].exists { app.buttons["Get Started"].tap() }

        // --- Main Tabs ---
        XCTAssertTrue(
            app.navigationBars["Places"].exists ||
            app.navigationBars["Места"].exists
        )
        snapshot("02-Places-List")

        // Открыть первую ячейку и сделать скрин детали (если есть)
        if app.tables.firstMatch.cells.count > 0 {
            app.tables.firstMatch.cells.element(boundBy: 0).tap()
            snapshot("03-POI-Detail")
            let close = app.buttons["xmark.circle.fill"]
            if close.exists { close.tap() }
        }

        // --- Map ---
        tapTab(labelEn: "Map", labelRu: "Карта")
        sleep(1)
        snapshot("04-Map")

        // --- Settings ---
        tapTab(labelEn: "Settings", labelRu: "Настройки")
        snapshot("05-Settings")
    }

    // MARK: - Helpers

    private func tapIfExists(_ el: XCUIElement, timeout: TimeInterval = 0.5) {
        if el.waitForExistence(timeout: timeout) { el.tap() }
    }

    private func tapTab(labelEn: String, labelRu: String) {
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons[labelEn].exists {
            tabBar.buttons[labelEn].tap()
        } else if tabBar.buttons[labelRu].exists {
            tabBar.buttons[labelRu].tap()
        } else if tabBar.buttons.count > 0 {
            tabBar.buttons.element(boundBy: 0).tap()
        }
    }
}
