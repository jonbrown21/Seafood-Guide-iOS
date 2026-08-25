import Foundation
import SwiftUI

struct GuideSource: Identifiable, Hashable {
    let title: String
    let url: URL

    var id: String { url.absoluteString }
}

struct SeafoodEntry: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let categoryIndex: Int
    let description: String
    let advice: String
    let region: String
    let status: String
    let sources: [GuideSource]

    init(
        name: String,
        categoryIndex: Int,
        description: String,
        advice: String,
        region: String,
        status: String,
        sources: [GuideSource] = []
    ) {
        self.name = name
        self.categoryIndex = categoryIndex
        self.description = description
        self.advice = advice
        self.region = region
        self.status = status
        self.sources = sources
    }
}

struct GuideArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let body: String
    let number: Int?
    let sources: [GuideSource]

    init(title: String, body: String, number: Int?, sources: [GuideSource] = []) {
        self.title = title
        self.body = body
        self.number = number
        self.sources = sources
    }
}

struct GuideSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let articles: [GuideArticle]
}

enum SeafoodCategory: Int, CaseIterable, Identifiable {
    case mild, flavorful, steak, small, shellfish, other, all, dirtyDozen

    static let homeFeatured: SeafoodCategory = .steak
    static let homeCarouselOrder: [SeafoodCategory] = [
        homeFeatured, .mild, .flavorful, .small, .shellfish, .other, .dirtyDozen
    ]

    var id: Int { rawValue }

    init?(xmlValue: String) {
        switch xmlValue {
        case "mild": self = .mild
        case "flavorful": self = .flavorful
        case "steak": self = .steak
        case "small": self = .small
        case "shellfish": self = .shellfish
        case "other": self = .other
        case "all": self = .all
        case "highestMercury": self = .dirtyDozen
        default: return nil
        }
    }
    var title: String {
        switch self {
        case .mild: "Mild fish"
        case .flavorful: "Flavorful fish"
        case .steak: "Steak-like fish"
        case .small: "Small fish"
        case .shellfish: "Shellfish"
        case .other: "Other seafood"
        case .all: "All seafood"
        case .dirtyDozen: "Highest mercury"
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
        case .dirtyDozen: "FDA choices to avoid for pregnancy and children"
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
