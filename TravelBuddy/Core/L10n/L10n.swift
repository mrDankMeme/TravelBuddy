//
//  L10n.swift
//  TravelBuddy
//

import Foundation

enum L10n {

    // MARK: - Internal helpers

    /// Возвращает локализованную строку по первому существующему ключу.
    private static func pick(_ keys: [String], _ comment: String) -> String {
        for k in keys {
            let v = NSLocalizedString(k, comment: comment)
            if v != k { return v } // ключ найден в .strings
        }
        // если ничего не нашли — вернём первую как есть (видно будет в UI)
        return NSLocalizedString(keys.first ?? "", comment: comment)
    }

    /// Формат для plural/параметров с фолбэком по нескольким ключам.
    private static func pickFormat(_ keys: [String], _ comment: String, _ args: CVarArg...) -> String {
        for k in keys {
            let fmt = NSLocalizedString(k, comment: comment)
            if fmt != k { return String(format: fmt, locale: .current, arguments: args) }
        }
        let fallback = NSLocalizedString(keys.first ?? "", comment: comment)
        return String(format: fallback, locale: .current, arguments: args)
    }

    // MARK: - Common
    static var alertOk: String { pick(["alert.ok"], "OK button") }
    static var alertErrorTitle: String { pick(["alert.error.title"], "Generic error alert title") }
    static var commonRetry: String { pick(["common.retry","list.retry"], "Retry") }
    static var commonClose: String { pick(["common.close"], "Close") }

    // MARK: - Tabs / Navigation titles
    static var tabPlaces: String { pick(["tab.places"], "Tab: Places") }
    static var tabMap: String { pick(["tab.map"], "Tab: Map") }
    static var tabSettings: String { pick(["tab.settings"], "Tab: Settings") }

    static var navPlacesTitle: String {
        pick(["nav.places.title","places.title","tab.places"], "Navigation title: Places")
    }
    static var navSettingsTitle: String {
        pick(["nav.settings.title","settings.title","tab.settings"], "Navigation title: Settings")
    }

    // MARK: - Settings
    static var settingsDarkMode: String {
        pick(["settings.darkmode","settings.dark_mode"], "Settings: Dark Mode")
    }
    static var settingsNotifications: String {
        pick(["settings.notifications"], "Settings: Notifications")
    }
    static var settingsPremiumUnlock: String {
        pick(["settings.premium.unlock"], "Settings: Unlock Premium")
    }
    static var settingsPremiumUnlocked: String {
        pick(["settings.premium.unlocked"], "Settings: Premium unlocked label")
    }

    // MARK: - List screen
    static var listCategoryTitle: String {
        pick(["list.category.title","places.category"], "Category picker title")
    }

    // Категории — поддерживаем обе схемы ключей
    static var catAll: String { pick(["category.all","places.category.all"], "Category: All") }
    static var catMonument: String { pick(["category.monument","places.category.monument"], "Category: Monument") }
    static var catMuseum: String { pick(["category.museum","places.category.museum"], "Category: Museum") }
    static var catCafe: String { pick(["category.cafe","places.category.cafe"], "Category: Cafe") }

    /// Плюралы «N places»
    static func listPlacesCount(_ n: Int) -> String {
        pickFormat(["list.places.count"], "Pluralized places count", n)
    }

    // MARK: - POI Detail / Snippet / Image
    static var detailLoadingAddress: String {
        pick(["detail.loading.address","poi.loading_address"], "Loading address…")
    }
    static var detailShare: String {
        pick(["detail.share","poi.share"], "Share button")
    }
    static var detailOpenInMaps: String {
        pick(["detail.openinmaps","poi.open_in_maps"], "Open in Maps")
    }

    static var snippetDetails: String { pick(["snippet.details","poi.details"], "Map snippet: Details") }
    static var snippetRoute: String { pick(["snippet.route","poi.route"], "Map snippet: Route") }

    static var imageNoImage: String { pick(["image.noimage","poi.image.none"], "No image placeholder") }
    static func imageInvalidPath(_ path: String) -> String {
        pickFormat(["image.invalid.path","poi.image.invalid_path"], "Invalid path", path)
    }
    static func imageMissingNamed(_ name: String) -> String {
        pickFormat(["poi.image.missing_named"], "Missing named image", name)
    }
    static func imagePath(_ path: String) -> String {
        pickFormat(["poi.image.path"], "Path label", path)
    }

    // MARK: - Onboarding (поддержка двух нейминг-схем)
    static var onboardingNext: String { pick(["onboarding.next","onb.next"], "Onboarding: Next") }
    static var onboardingBack: String { pick(["onboarding.back","onb.back"], "Onboarding: Back") }
    static var onboardingGetStarted: String { pick(["onboarding.get_started","onb.getstarted"], "Onboarding: Get Started") }

    static var onboardingTitle1: String { pick(["onboarding.title1","onb.p1.title"], "Onb page1 title") }
    static var onboardingDesc1: String  { pick(["onboarding.desc1","onb.p1.desc"], "Onb page1 desc") }
    static var onboardingTitle2: String { pick(["onboarding.title2","onb.p2.title"], "Onb page2 title") }
    static var onboardingDesc2: String  { pick(["onboarding.desc2","onb.p2.desc"], "Onb page2 desc") }
    static var onboardingTitle3: String { pick(["onboarding.title3","onb.p3.title"], "Onb page3 title") }
    static var onboardingDesc3: String  { pick(["onboarding.desc3","onb.p3.desc"], "Onb page3 desc") }

    // Для кода, который уже использует onb.*
    static var onbNext: String { onboardingNext }
    static var onbBack: String { onboardingBack }
    static var onbGetStarted: String { onboardingGetStarted }
    static var onbPage1Title: String { onboardingTitle1 }
    static var onbPage1Desc: String { onboardingDesc1 }
    static var onbPage2Title: String { onboardingTitle2 }
    static var onbPage2Desc: String { onboardingDesc2 }
    static var onbPage3Title: String { onboardingTitle3 }
    static var onbPage3Desc: String { onboardingDesc3 }

    // MARK: - DeepLink parsing errors
    static var deeplinkUnknownHost: String { pick(["deeplink.unknown_host"], "Unsupported link host") }
    static var deeplinkInvalidCoords: String { pick(["deeplink.invalid_coords"], "Invalid coordinates in deeplink") }
    static var deeplinkUnsupportedScheme: String { pick(["deeplink.unsupported_scheme"], "Unsupported url scheme") }

    // MARK: - DeepLink business errors
    static func deeplinkPoiNotFound(_ id: Int) -> String {
        pickFormat(["deeplink.poi.not_found"], "POI not found by ID", id)
    }
}
