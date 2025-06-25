//
//  DesignTokens.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import UIKit

public enum DesignTokens {
  // MARK: Colors
  public static let colorPrimary = UIColor(hex: "#0055FF")!
  public static let colorBackground = UIColor { trait in
    trait.userInterfaceStyle == .dark
      ? UIColor(hex: "#000000")!
      : UIColor(hex: "#FFFFFF")!
  }

  // MARK: Typography
  public static let fontHeadline = UIFont.systemFont(ofSize: 24, weight: .bold)
  public static let fontBody     = UIFont.systemFont(ofSize: 16, weight: .regular)

  // MARK: Spacing
  public static let spacingSmall  = CGFloat(8)
  public static let spacingMedium = CGFloat(16)
}

