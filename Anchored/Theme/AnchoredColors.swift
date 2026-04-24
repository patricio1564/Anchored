//
//  AnchoredColors.swift
//  Anchored
//
//  Warm, modern aesthetic per the PRD: cream/parchment background, deep navy
//  for text, gold/amber accents for highlights and CTAs. All colors are
//  defined programmatically so the project compiles without asset catalog
//  entries; when you're ready to tune them in Xcode, promote these into
//  Colors.xcassets with dark mode variants and delete this file.
//

import SwiftUI

enum AnchoredColors {
    // MARK: - Brand Primary

    /// Warm cream / parchment — main background
    static let parchment = Color(
        light: Color(red: 249/255, green: 245/255, blue: 239/255),  // #F9F5EF
        dark:  Color(red: 22/255,  green: 22/255,  blue: 28/255)    // warm near-black
    )

    /// Deep navy — primary text and headers
    static let navy = Color(
        light: Color(red: 27/255, green: 42/255, blue: 74/255),     // #1B2A4A
        dark:  Color(red: 240/255, green: 238/255, blue: 230/255)   // warm off-white
    )

    /// Gold / amber — highlights and CTAs
    static let amber = Color(
        light: Color(red: 201/255, green: 150/255, blue: 58/255),   // #C9963A
        dark:  Color(red: 220/255, green: 170/255, blue: 80/255)    // brighter gold for dark mode
    )

    // MARK: - Semantic

    /// Cards, sheets, elevated surfaces
    static let card = Color(
        light: Color.white,
        dark:  Color(red: 32/255, green: 32/255, blue: 38/255)
    )

    /// Subtle muted text
    static let muted = Color(
        light: Color(red: 115/255, green: 115/255, blue: 115/255),
        dark:  Color(red: 160/255, green: 160/255, blue: 160/255)
    )

    /// Hairline borders, dividers
    static let border = Color(
        light: Color(red: 230/255, green: 225/255, blue: 215/255),
        dark:  Color(red: 48/255, green: 48/255, blue: 54/255)
    )

    /// Tinted background for amber accents (like verse cards)
    static let amberSoft = Color(
        light: Color(red: 252/255, green: 242/255, blue: 220/255),
        dark:  Color(red: 48/255, green: 40/255, blue: 24/255)
    )

    // MARK: - State

    static let success = Color(red: 34/255, green: 139/255, blue: 87/255)
    static let error   = Color(red: 200/255, green: 62/255, blue: 62/255)
    static let streak  = Color(red: 240/255, green: 120/255, blue: 56/255)  // flame orange
}

// MARK: - Convenience Color Initializer

private extension Color {
    /// Creates a Color that adapts to light/dark mode.
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
        #else
        self = light
        #endif
    }
}
