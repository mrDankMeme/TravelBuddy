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

        // SnapshotHelper сам проставит язык/локаль и служебные ключи fastlane.
        setupSnapshot(app)

        // НИКАКИХ кастомных launchArguments — стартуем «как после свежей установки».
        app.launch()

        // Перехватываем системные алерты (локация и др.), чтобы тест не стопорился.
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            // Пробуем разрешить доступ или закрыть алерт любым подходящим вариантом.
            let buttons = [
                "Allow While Using App", "Allow Once", "Allow",
                "OK", "Continue", "Don’t Allow", "Don\'t Allow",
                "Разрешить при использовании", "Разрешить один раз", "Разрешить",
                "ОК", "Продолжить", "Не разрешать"
            ]
            for title in buttons {
                let b = alert.buttons[title]
                if b.exists { b.tap(); return true }
            }
            return false
        }

        // После регистрации UIInterruptionMonitor надо «пнуть» приложение,
        // чтобы алерт был обработан.
        app.activate()
    }

    // MARK: - Главный сценарий скриншотов

    func testSnapshot_Onboarding_List_Map_Settings() {
        // --- 01: Onboarding page 1 ---
        let onboardingNext = app.buttons["onboarding.next"]
        let onboardingNextTextEn = app.buttons["Next"]
        let onboardingNextTextRu = app.buttons["Далее"]

        XCTAssertTrue(
            onboardingNext.waitForExistence(timeout: 15)
            || onboardingNextTextEn.waitForExistence(timeout: 15)
            || onboardingNextTextRu.waitForExistence(timeout: 15),
            "Onboarding page 1 did not appear"
        )
        snapshot("01-Onboarding-Page1")

        // Переходим на 2 страницу
        tapIfExists(onboardingNext, fallbackMany: [onboardingNextTextEn, onboardingNextTextRu], timeout: 5)

        // Переходим на 3 страницу
        let onboardingNext2 = app.buttons["onboarding.next"]
        let onboardingNextText2En = app.buttons["Next"]
        let onboardingNextText2Ru = app.buttons["Далее"]
        tapIfExists(onboardingNext2, fallbackMany: [onboardingNextText2En, onboardingNextText2Ru], timeout: 5)

        // Завершаем онбординг
        let getStarted = app.buttons["onboarding.get_started"]
        let getStartedTextEn = app.buttons["Get Started"]
        let getStartedTextRu = app.buttons["Начать"]
        tapIfExists(getStarted, fallbackMany: [getStartedTextEn, getStartedTextRu], timeout: 10)

        // --- 02: Places list ---
        let navPlaces = app.navigationBars["Places"]
        let navPlacesRu = app.navigationBars["Места"]
        XCTAssertTrue(navPlaces.waitForExistence(timeout: 15) || navPlacesRu.waitForExistence(timeout: 15),
                      "Places screen did not appear")

        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 30), "Places table did not appear")

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 30),
                      "Places first cell did not appear")

        snapshot("02-Places-List")

        // --- 03: POI Detail ---
        firstCell.tap()

        // Ждём кнопку закрытия (у тебя это системная иконка).
        let closeButton = app.buttons["xmark.circle.fill"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 10), "POI Detail did not open")

        snapshot("03-POI-Detail")

        closeButton.tap()

        // --- 04: Map ---
        tapTab(labelEn: "Map", labelRu: "Карта")

        // Обработка потенциального системного алерта (локация/карта).
        app.tap()

        let legal = app.staticTexts["Legal"]
        let legalRu = app.staticTexts["Правовые документы"]
        XCTAssertTrue(legal.waitForExistence(timeout: 20) || legalRu.waitForExistence(timeout: 20),
                      "Map did not load 'Legal' label")

        snapshot("04-Map")

        // --- 05: Settings ---
        tapTab(labelEn: "Settings", labelRu: "Настройки")

        let settingsTitle = app.staticTexts["Settings"]
        let settingsTitleRu = app.staticTexts["Настройки"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 15) || settingsTitleRu.waitForExistence(timeout: 15),
                      "Settings screen did not appear")

        snapshot("05-Settings")
    }

    // MARK: - Helpers

    /// Тапаем element, если он существует; иначе — пробуем fallback’и по очереди.
    private func tapIfExists(_ element: XCUIElement,
                             fallbackMany: [XCUIElement] = [],
                             timeout: TimeInterval = 2) {
        if element.waitForExistence(timeout: timeout) {
            element.tap()
            return
        }
        for fb in fallbackMany {
            if fb.waitForExistence(timeout: timeout) {
                fb.tap()
                return
            }
        }
        XCTFail("Neither main element nor fallbacks existed for tap")
    }

    /// Переход по табу: по идентификаторам, потом по локализованным лейблам, затем первый таб.
    private func tapTab(labelEn: String, labelRu: String) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar not found")

        let idCandidates = ["tab.places", "tab.map", "tab.settings"]
        for id in idCandidates {
            let btn = tabBar.buttons[id]
            if btn.exists { btn.tap(); return }
        }

        let en = tabBar.buttons[labelEn]
        let ru = tabBar.buttons[labelRu]
        if en.exists { en.tap(); return }
        if ru.exists { ru.tap(); return }

        if tabBar.buttons.count > 0 {
            tabBar.buttons.element(boundBy: 0).tap()
        } else {
            XCTFail("No tabs found")
        }
    }
}
