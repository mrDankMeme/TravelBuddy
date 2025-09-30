//
//  L10n.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/28/25.
//


import Foundation

enum L10n {

    // MARK: - Common
    static var alertOk: String { NSLocalizedString("alert.ok", comment: "OK button") }
    static var alertErrorTitle: String { NSLocalizedString("alert.error.title", comment: "Generic error alert title") }

    // MARK: - Tabs / Titles
    static var tabPlaces: String { NSLocalizedString("tab.places", comment: "Tab title: Places") }
    static var tabMap: String { NSLocalizedString("tab.map", comment: "Tab title: Map") }
    static var tabSettings: String { NSLocalizedString("tab.settings", comment: "Tab title: Settings") }

    static var navSettingsTitle: String { NSLocalizedString("nav.settings.title", comment: "Navigation title for Settings") }
    static var navPlacesTitle: String { NSLocalizedString("nav.places.title", comment: "Navigation title for Places") }

    // MARK: - List screen
    static var listCategoryTitle: String { NSLocalizedString("list.category.title", comment: "Category picker title") }
    static var listRetry: String { NSLocalizedString("list.retry", comment: "Retry button") }
    static func listPlacesCount(_ n: Int) -> String {
        let fmt = NSLocalizedString("list.places.count", comment: "Pluralized count of places")
        return String.localizedStringWithFormat(fmt, n)
    }

    // Category display names
    static var catAll: String { NSLocalizedString("category.all", comment: "All category") }
    static var catMonument: String { NSLocalizedString("category.monument", comment: "Monument category") }
    static var catMuseum: String { NSLocalizedString("category.museum", comment: "Museum category") }
    static var catCafe: String { NSLocalizedString("category.cafe", comment: "Cafe category") }

    // MARK: - POI Detail
    static var detailLoadingAddress: String { NSLocalizedString("detail.loading.address", comment: "Loading address…") }
    static var detailShare: String { NSLocalizedString("detail.share", comment: "Share button") }
    static var detailOpenInMaps: String { NSLocalizedString("detail.openinmaps", comment: "Open in Maps button") }

    // MARK: - Onboarding
    static var onbNext: String { NSLocalizedString("onb.next", comment: "Next button") }
    static var onbBack: String { NSLocalizedString("onb.back", comment: "Back button") }
    static var onbGetStarted: String { NSLocalizedString("onb.getstarted", comment: "Get Started button") }

    static var onbPage1Title: String { NSLocalizedString("onb.p1.title", comment: "Onboarding page 1 title") }
    static var onbPage1Desc: String { NSLocalizedString("onb.p1.desc", comment: "Onboarding page 1 description") }
    static var onbPage2Title: String { NSLocalizedString("onb.p2.title", comment: "Onboarding page 2 title") }
    static var onbPage2Desc: String { NSLocalizedString("onb.p2.desc", comment: "Onboarding page 2 description") }
    static var onbPage3Title: String { NSLocalizedString("onb.p3.title", comment: "Onboarding page 3 title") }
    static var onbPage3Desc: String { NSLocalizedString("onb.p3.desc", comment: "Onboarding page 3 description") }

    // MARK: - DeepLink parsing errors
    static var deeplinkUnknownHost: String { NSLocalizedString("deeplink.unknown_host", comment: "Unsupported link host") }
    static var deeplinkInvalidCoords: String { NSLocalizedString("deeplink.invalid_coords", comment: "Invalid coordinates in deeplink") }
    static var deeplinkUnsupportedScheme: String { NSLocalizedString("deeplink.unsupported_scheme", comment: "Unsupported url scheme") }

    // MARK: - DeepLink business errors
    static func deeplinkPoiNotFound(_ id: Int) -> String {
        let format = NSLocalizedString("deeplink.poi.not_found", comment: "POI not found by ID")
        return String(format: format, locale: Locale.current, arguments: [id])
    }

    // MARK: - Misc UI
    static var imageNoImage: String { NSLocalizedString("image.noimage", comment: "No image placeholder") }
    static func imageInvalidPath(_ path: String) -> String {
        let format = NSLocalizedString("image.invalid.path", comment: "Invalid image path message")
        return String(format: format, path)
    }
}
