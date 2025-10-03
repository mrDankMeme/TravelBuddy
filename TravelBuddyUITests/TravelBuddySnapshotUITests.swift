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

        // Если используете fastlane snapshot, setupSnapshot(app) уже добавит свои аргументы/локаль.
        // Если у вас подключен SnapshotHelper.swift — раскомментируйте:
        // setupSnapshot(app)

        // Рекомендовано пробрасывать флаги (опционально, если поддержаны приложением):
        // app.launchArguments += ["-uiTesting", "1", "-uiMockData", "1", "-uiPremium", "locked", "-skipOnboarding", "YES"]

        app.launch()
    }

    // MARK: - Главный сценарий скриншотов

     func testSnapshot_Onboarding_List_Map_Settings() {
        // --- 01: Onboarding page 1 ---
        // Ждем появления кнопки онбординга (id или текст), чтобы не сделать снимок "раньше времени"
        let onboardingNext = app.buttons["onboarding.next"]
        let onboardingNextText = app.buttons["Next"]
        XCTAssertTrue(
            onboardingNext.waitForExistence(timeout: 5) || onboardingNextText.waitForExistence(timeout: 5),
            "Onboarding page 1 did not appear"
        )
        snapshot("01-Onboarding-Page1")

        // Переходим на 2 страницу
        tapIfExists(onboardingNext, fallback: onboardingNextText)

        // Переходим на 3 страницу
        let onboardingNext2 = app.buttons["onboarding.next"]
        let onboardingNextText2 = app.buttons["Next"]
        tapIfExists(onboardingNext2, fallback: onboardingNextText2)

        // Завершаем онбординг
        let getStarted = app.buttons["onboarding.get_started"]
        let getStartedText = app.buttons["Get Started"]
        tapIfExists(getStarted, fallback: getStartedText)

        // --- 02: Places list ---
        // Убедимся, что мы на экране Places/Места
        let navPlaces = app.navigationBars["Places"]
        let navPlacesRu = app.navigationBars["Места"]
        XCTAssertTrue(navPlaces.waitForExistence(timeout: 5) || navPlacesRu.waitForExistence(timeout: 5),
                      "Places screen did not appear")

        // Ждем таблицу и первую ячейку (это убирает "ромашку" на снимке)
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Places table did not appear")

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 20),
                      "Places first cell did not appear (waited for remote->fallback local)")

        snapshot("02-Places-List")

        // --- 03: POI Detail ---
        firstCell.tap()

        // Ждем появления элемента на экране детали:
        // используем кнопку закрытия, которая у тебя есть ("xmark.circle.fill").
        let closeButton = app.buttons["xmark.circle.fill"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5), "POI Detail did not open")

        // Если есть доступный стабильный элемент (заголовок/кнопка share) — можно ждать его:
        // let share = app.buttons["detail.share"] // если в App выставлен identifier
        // _ = share.waitForExistence(timeout: 2)

        snapshot("03-POI-Detail")

        closeButton.tap()

        // --- 04: Map ---
        tapTab(labelEn: "Map", labelRu: "Карта")

        // Ждем устойчивый системный элемент карты внизу (Legal / Правовые документы)
        let legal = app.staticTexts["Legal"]
        let legalRu = app.staticTexts["Правовые документы"]
        XCTAssertTrue(legal.waitForExistence(timeout: 10) || legalRu.waitForExistence(timeout: 10),
                      "Map did not load 'Legal' label")

        snapshot("04-Map")

        // --- 05: Settings ---
        tapTab(labelEn: "Settings", labelRu: "Настройки")

        let settingsTitle = app.staticTexts["Settings"]
        let settingsTitleRu = app.staticTexts["Настройки"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5) || settingsTitleRu.waitForExistence(timeout: 5),
                      "Settings screen did not appear")

        snapshot("05-Settings")
    }

    // MARK: - Helpers

    /// Тапаем element, если он существует; иначе — fallback.
    private func tapIfExists(_ element: XCUIElement, fallback: XCUIElement? = nil, timeout: TimeInterval = 2) {
        if element.waitForExistence(timeout: timeout) {
            element.tap()
        } else if let fb = fallback, fb.waitForExistence(timeout: timeout) {
            fb.tap()
        } else {
            XCTFail("Neither main element nor fallback existed for tap")
        }
    }

    /// Переход по табу. Сначала пытаемся по айдишникам (если добавишь их в приложении),
    /// затем по локализованным текстам, затем по первому табу.
    private func tapTab(labelEn: String, labelRu: String) {
        let tabBar = app.tabBars.firstMatch

        // 1) Попытка по identifier (добавь в приложении, если захочешь):
        let idCandidates = ["tab.places", "tab.map", "tab.settings"]
        for id in idCandidates {
            let btn = tabBar.buttons[id]
            if btn.exists {
                btn.tap()
                return
            }
        }

        // 2) По текстовым лейблам (как сейчас)
        let en = tabBar.buttons[labelEn]
        let ru = tabBar.buttons[labelRu]
        if en.exists { en.tap(); return }
        if ru.exists { ru.tap(); return }

        // 3) Фолбэк — любой первый таб
        if tabBar.buttons.count > 0 {
            tabBar.buttons.element(boundBy: 0).tap()
        } else {
            XCTFail("No tabs found")
        }
    }
}

 
