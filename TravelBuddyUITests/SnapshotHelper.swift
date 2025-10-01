//
//  SnapshotHelper.swift
//  TravelBuddyUITests
//
//  Minimal helper for fastlane snapshot.
//  Based on fastlane snapshot template, simplified for our needs.
//

import Foundation
import XCTest

public enum Snapshot {
    public static var app: XCUIApplication!

    /// Call from setUp() before app.launch()
    public static func setup(_ app: XCUIApplication) {
        Snapshot.app = app
        app.launchArguments += ["-ui_testing"]
        // Fastlane snapshot signals via env
        if ProcessInfo.processInfo.environment["FASTLANE_SNAPSHOT"] == "YES" {
            app.launchArguments += ["-FASTLANE_SNAPSHOT", "1"]
        }
    }

    /// Takes a screenshot and saves it in the test attachments.
    /// fastlane will collect them from DerivedData.
    @discardableResult
    public static func take(_ name: String, timeWaiting seconds: TimeInterval = 0.2) -> XCTAttachment {
        if seconds > 0 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: seconds))
        }

        let screenshot  = XCUIScreen.main.screenshot()
        let attachment  = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways

        XCTContext.runActivity(named: "Snapshot \(name)") { activity in
            // именно так сейчас добавляют вложение
            activity.add(attachment)
        }

        return attachment
    }

}
