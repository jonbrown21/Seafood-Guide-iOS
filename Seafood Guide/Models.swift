import Foundation
import SwiftUI

struct SeafoodEntry: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let categoryIndex: Int
    let description: String
    let advice: String
    let region: String
    let status: String
}

struct GuideArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let body: String
    let number: Int?
}

struct GuideSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let articles: [GuideArticle]
}

enum SeafoodCategory: Int, CaseIterable, Identifiable {
    case mild, flavorful, steak, small, shellfish, other, all, dirtyDozen

    var id: Int { rawValue }
    var title: String {
        switch self {
        case .mild: "Mild fish"
        case .flavorful: "Flavorful fish"
        case .steak: "Steak-like fish"
        case .small: "Small fish"
        case .shellfish: "Shellfish"
        case .other: "Other seafood"
        case .all: "All seafood"
        case .dirtyDozen: "Dirty dozen"
        }
    }
    var symbolName: String {
        switch self {
        case .mild: "fish.fill"
        case .flavorful: "flame.fill"
        case .steak: "fork.knife"
        case .small: "fish.fill"
        case .shellfish: "fossil.shell.fill"
        case .other: "water.waves"
        case .all: "magnifyingglass"
        case .dirtyDozen: "exclamationmark.shield.fill"
        }
    }
    var subtitle: String {
        switch self {
        case .mild: "Gentle flavor and easy to pair"
        case .flavorful: "Bolder flavor for the table"
        case .steak: "Firm, meaty textures"
        case .small: "Small fish with big character"
        case .shellfish: "Clams, shrimp, scallops and more"
        case .other: "Everything else from the sea"
        case .all: "Browse the complete guide"
        case .dirtyDozen: "Species to approach with care"
        }
    }

    var tintColor: Color {
        switch self {
        case .mild: .seafoam
        case .flavorful: .coral
        case .steak: .sunshine
        case .small: .sky
        case .shellfish: .lavender
        case .other: .sand
        case .all: .seafoam
        case .dirtyDozen: .coral
        }
    }
}
