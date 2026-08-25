import SwiftUI
import CoreTransferable
import EventKit
import UniformTypeIdentifiers

struct GuideRootView: View {
    @ObservedObject var store: GuideStore

    var body: some View {
        TabView {
            Tab("Explore", systemImage: "safari.fill") {
                NavigationStack { ExploreView(store: store) }
            }
            Tab("Glossary", systemImage: "books.vertical.fill") {
                NavigationStack { ArticleListView(title: "Seafood glossary", articles: store.glossary) }
            }
            Tab("Risks", systemImage: "exclamationmark.shield.fill") {
                NavigationStack {
                    ArticleListView(
                        title: "Aquaculture risks",
                        articles: store.aquacultureRisks,
                        presentation: .risks
                    )
                }
            }
            Tab("About", systemImage: "info.circle.fill") {
                NavigationStack { AboutView(sections: store.aboutSections) }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExploreView: View {
    @ObservedObject var store: GuideStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            OceanBackground()
            if horizontalSizeClass == .regular {
                TabletExploreView(store: store)
            } else {
                CompactExploreView(store: store)
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct CompactExploreView: View {
    @ObservedObject var store: GuideStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                ExploreHeading()
                    .padding(.horizontal, 20)

                BrowseAllCard(store: store, presentation: .compact)
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Browse by category")
                            .font(.title3.weight(.bold))
                        Spacer()
                        Label("Swipe", systemImage: "arrow.left.and.right")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 14) {
                            ForEach(SeafoodCategory.homeCarouselOrder) { category in
                                NavigationLink {
                                    SeafoodListView(category: category, store: store)
                                } label: {
                                    CategoryCard(category: category)
                                }
                                .buttonStyle(.plain)
                                .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 14)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .scrollBounceBehavior(.basedOnSize)
                }
                .padding(.horizontal, 20)

                LearnSection(store: store)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 28)
        }
    }
}

private struct TabletExploreView: View {
    @ObservedObject var store: GuideStore
    @State private var categoryCardHeight: CGFloat = 0

    private let categoryColumns = [GridItem(.adaptive(minimum: 230, maximum: 320), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 34) {
                HStack(alignment: .bottom, spacing: 24) {
                    ExploreHeading()
                    Spacer()
                    Label("\(store.seafood.count) sourced profiles", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ocean)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background(.white.opacity(0.82), in: Capsule())
                }

                Grid(horizontalSpacing: 16) {
                    GridRow(alignment: .top) {
                        BrowseAllCard(store: store, presentation: .wide)
                        GuidanceOverviewCard()
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Explore the guide")
                        .font(.title2.weight(.bold))

                    LazyVGrid(columns: categoryColumns, alignment: .leading, spacing: 16) {
                        ForEach(SeafoodCategory.allCases) { category in
                            NavigationLink {
                                SeafoodListView(category: category, store: store)
                            } label: {
                                TabletCategoryCard(
                                    category: category,
                                    count: store.seafood(in: category).count,
                                    sharedHeight: categoryCardHeight
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onPreferenceChange(TabletCategoryCardHeightKey.self) { measuredHeight in
                        categoryCardHeight = measuredHeight
                    }
                }

                LearnSection(store: store, titleFont: .title2.weight(.bold), isWide: true)
            }
            .frame(maxWidth: 1280)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical, 36)
        }
    }
}

private struct ExploreHeading: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SEAFOOD GUIDE")
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(Color.ocean)
            Text("Choose seafood with confidence.")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.8)
            Text("Compare flavor, texture, sourcing advice, and species details.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

private enum BrowseAllPresentation {
    case compact, wide
}

private struct BrowseAllCard: View {
    @ObservedObject var store: GuideStore
    let presentation: BrowseAllPresentation

    var body: some View {
        NavigationLink {
            SeafoodListView(category: .all, store: store)
        } label: {
            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Browse all seafood")
                        .font(presentation == .wide ? .title.weight(.bold) : .title2.weight(.bold))
                    Text("Find a species or discover something new")
                        .font(presentation == .wide ? .body : .subheadline)
                        .foregroundStyle(Color.ink.opacity(0.7))
                    Label("Open \(store.seafood.count) profiles", systemImage: "arrow.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ocean)
                }
                Spacer(minLength: 8)
                CategorySymbol(category: .all)
                    .frame(width: presentation == .wide ? 104 : 82, height: presentation == .wide ? 104 : 82)
            }
            .padding(presentation == .wide ? 28 : 22)
            .frame(
                maxWidth: .infinity,
                maxHeight: presentation == .wide ? .infinity : nil,
                alignment: .leading
            )
            .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Image(systemName: "sparkles")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.ocean.opacity(0.7))
                    .padding(18)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct GuidanceOverviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Read the guidance")
                    .font(.title2.weight(.bold))
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(Color.ocean)
            }

            Text("Health guidance and sourcing details answer different questions. Every profile keeps them separate and links to its sources.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                GuidanceChip(title: "Best choice", symbol: "checkmark", color: .seafoam)
                GuidanceChip(title: "Good choice", symbol: "minus", color: .sunshine)
                GuidanceChip(title: "Avoid", symbol: "exclamationmark", color: .coral)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }
}

private struct GuidanceChip: View {
    let title: String
    let symbol: String
    let color: Color

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(color, in: Capsule())
    }
}

private struct TabletCategoryCard: View {
    let category: SeafoodCategory
    let count: Int
    let sharedHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                CategorySymbol(category: category)
                    .frame(width: 62, height: 62)
                Spacer()
                Text("\(count)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ocean)
                    .contentTransition(.numericText())
            }
            Text(category.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ink)
            Text(category.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: TabletCategoryCardHeightKey.self,
                    value: proxy.size.height
                )
            }
        }
        .frame(maxWidth: .infinity, minHeight: sharedHeight, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }
}

private struct TabletCategoryCardHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct LearnSection: View {
    @ObservedObject var store: GuideStore
    var titleFont: Font = .title3.weight(.bold)
    var isWide = false

    private var columns: [GridItem] {
        if isWide {
            return [GridItem(.flexible(), spacing: 12), GridItem(.flexible())]
        }
        return [GridItem(.adaptive(minimum: 160), spacing: 12)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Learn before you buy")
                .font(titleFont)

            LazyVGrid(columns: columns, spacing: 12) {
                NavigationLink {
                    ArticleListView(title: "Seafood glossary", articles: store.glossary)
                } label: {
                    GuideShortcutCard(
                        title: "Seafood glossary",
                        subtitle: "Decode labels, terms, and sourcing language",
                        symbol: "books.vertical.fill",
                        color: .sky
                    )
                }
                NavigationLink {
                    ArticleListView(
                        title: "Aquaculture risks",
                        articles: store.aquacultureRisks,
                        presentation: .risks
                    )
                } label: {
                    GuideShortcutCard(
                        title: "Aquaculture risks",
                        subtitle: "Know what to examine before choosing farmed seafood",
                        symbol: "exclamationmark.shield.fill",
                        color: .coral
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct CategoryCard: View {
    let category: SeafoodCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CategorySymbol(category: category)
                .frame(maxWidth: .infinity)
                .frame(height: 112)
            Text(category.title).font(.headline).foregroundStyle(Color.ink)
            Text(category.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct CategorySymbol: View {
    let category: SeafoodCategory

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(category.tintColor)
            Image(systemName: category.symbolName)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Color.ocean)
        }
    }
}

struct GuideShortcutCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.ocean)
                .frame(width: 46, height: 46)
                .background(color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.ink)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            Spacer(minLength: 0)
            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.ocean)
        }
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .leading)
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }
}

struct SeafoodListView: View {
    let category: SeafoodCategory
    @ObservedObject var store: GuideStore
    @State private var query = ""
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var categoryEntries: [SeafoodEntry] {
        store.seafood(in: category)
    }

    private var filtered: [SeafoodEntry] {
        guard !query.isEmpty else { return categoryEntries }
        return categoryEntries.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.description.localizedCaseInsensitiveContains(query)
                || $0.region.localizedCaseInsensitiveContains(query)
        }
    }

    private let compactColumns = [GridItem(.adaptive(minimum: 310, maximum: 540), spacing: 14)]
    private let tabletColumns = [GridItem(.flexible(), spacing: 18), GridItem(.flexible())]

    var body: some View {
        ZStack {
            OceanBackground()

            ScrollView {
                if horizontalSizeClass == .regular {
                    VStack(alignment: .leading, spacing: 22) {
                        TabletSeafoodListHeader(category: category, count: filtered.count)

                        LazyVGrid(columns: tabletColumns, alignment: .leading, spacing: 18) {
                            ForEach(filtered) { fish in
                                NavigationLink {
                                    SeafoodDetailView(entry: fish, relatedEntries: categoryEntries)
                                } label: {
                                    TabletSeafoodListCard(entry: fish)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: 1280)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 24)
                } else {
                    LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 14) {
                        ForEach(filtered) { fish in
                            NavigationLink {
                                SeafoodDetailView(entry: fish, relatedEntries: categoryEntries)
                            } label: {
                                SeafoodListRow(entry: fish)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: 1180)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
            }
        }
        .navigationTitle(category.title)
        .searchable(text: $query, prompt: "Search seafood")
    }
}

private struct TabletSeafoodListHeader: View {
    let category: SeafoodCategory
    let count: Int

    var body: some View {
        HStack(spacing: 22) {
            CategorySymbol(category: category)
                .frame(width: 88, height: 88)

            VStack(alignment: .leading, spacing: 6) {
                Text(category.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                Text(category.subtitle)
                    .font(.title3)
                    .foregroundStyle(Color.ink.opacity(0.7))
            }

            Spacer(minLength: 20)

            Label("\(count) profiles", systemImage: "square.grid.2x2.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ocean)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(.white.opacity(0.8), in: Capsule())
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(category.tintColor.opacity(0.78), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct TabletSeafoodListCard: View {
    let entry: SeafoodEntry

    private var category: SeafoodCategory {
        SeafoodCategory(rawValue: entry.categoryIndex) ?? .other
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: category.symbolName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.ocean)
                    .frame(width: 56, height: 56)
                    .background(category.tintColor, in: RoundedRectangle(cornerRadius: 17, style: .continuous))

                VStack(alignment: .leading, spacing: 7) {
                    Text(entry.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    SeafoodGuidanceBadge(status: entry.status)
                }

                Spacer(minLength: 8)
                CardChevron()
            }

            Text(entry.description)
                .font(.body)
                .foregroundStyle(Color.ink.opacity(0.72))
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            if !entry.region.isEmpty {
                Label(entry.region, systemImage: "tag.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.ocean)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

private struct SeafoodListRow: View {
    let entry: SeafoodEntry

    private var category: SeafoodCategory {
        SeafoodCategory(rawValue: entry.categoryIndex) ?? .other
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: category.symbolName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ocean)
                .frame(width: 46, height: 46)
                .background(category.tintColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                Text(entry.name)
                    .font(.headline)
                    .foregroundStyle(Color.ink)

                Text(entry.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                SeafoodGuidanceBadge(status: entry.status)
            }

            Spacer(minLength: 4)

            CardChevron()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.055), radius: 9, y: 4)
    }
}

private struct CardChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.ocean)
            .frame(width: 30, height: 30)
            .background(Color.sky.opacity(0.7), in: Circle())
            .accessibilityHidden(true)
    }
}

private struct SeafoodGuidanceBadge: View {
    let status: String

    private var appearance: (title: String, symbol: String, color: Color) {
        switch status {
        case "best": ("Best choice", "checkmark", .seafoam)
        case "good": ("Good choice", "minus", .sunshine)
        case "avoid": ("Highest mercury", "exclamationmark", .coral)
        default: ("Check guidance", "questionmark", .sky)
        }
    }

    var body: some View {
        Label(appearance.title, systemImage: appearance.symbol)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(appearance.color, in: Capsule())
    }
}

struct SeafoodDetailView: View {
    let entry: SeafoodEntry
    let relatedEntries: [SeafoodEntry]
    @State private var shareImage: SeafoodShareImage?
    @StateObject private var reminderStore = SeafoodReminderStore()
    @AppStorage("shoppingListIdentifier") private var shoppingListIdentifier = ""
    @State private var showingListPicker = false
    @State private var showingRemindersPermissionAlert = false
    @State private var reminderErrorMessage: String?
    @State private var addToListState: AddToListState = .idle
    @Environment(\.openURL) private var openURL
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(entry: SeafoodEntry, relatedEntries: [SeafoodEntry] = []) {
        self.entry = entry
        self.relatedEntries = relatedEntries
    }

    private var category: SeafoodCategory {
        SeafoodCategory(rawValue: entry.categoryIndex) ?? .other
    }

    private var related: [SeafoodEntry] {
        Array(relatedEntries.filter { $0.id != entry.id }.prefix(4))
    }

    var body: some View {
        ZStack {
            OceanBackground()

            ScrollView {
                if horizontalSizeClass == .regular {
                    tabletContent
                } else {
                    compactContent
                }
            }
        }
        .navigationTitle("Seafood details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingListPicker) {
            ReminderListPicker(lists: reminderStore.lists) { list in
                shoppingListIdentifier = list.calendarIdentifier
                showingListPicker = false
                add(entry, to: list)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Reminders Access Needed", isPresented: $showingRemindersPermissionAlert) {
            Button("Not Now", role: .cancel) {}
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            }
        } message: {
            Text("Allow Reminders access in Settings to add seafood to a shopping list.")
        }
        .alert("Couldn’t Add to List", isPresented: reminderErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(reminderErrorMessage ?? "Please try again.")
        }
        .sensoryFeedback(.success, trigger: addToListState == .added)
        .task {
            if shareImage == nil {
                shareImage = renderShareImage()
            }
        }
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 26) {
            speciesIdentityCard
            recommendationCard
            whatToKnowCard
            SourceLinksView(sources: entry.sources)
            actionButtons
                .padding(.bottom, 24)
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }

    private var tabletContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 20) {
                    speciesIdentityCard
                    recommendationCard
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(alignment: .leading, spacing: 20) {
                    whatToKnowCard
                    SourceLinksView(sources: entry.sources)
                    actionButtons
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            if !related.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("More \(category.title.lowercased())")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.ink)
                        Spacer()
                        Text("Continue exploring")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 240), spacing: 14)],
                        alignment: .leading,
                        spacing: 14
                    ) {
                        ForEach(related) { relatedEntry in
                            NavigationLink {
                                SeafoodDetailView(entry: relatedEntry, relatedEntries: relatedEntries)
                            } label: {
                                RelatedSeafoodCard(entry: relatedEntry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 1180)
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
    }

    private var speciesIdentityCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: horizontalSizeClass == .regular ? category.symbolName : "fish.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.ocean)
                    .frame(width: 58, height: 58)
                    .background(
                        horizontalSizeClass == .regular ? category.tintColor : Color.seafoam,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )

                Spacer()

                Text("SPECIES GUIDE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Color.ocean)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.sky.opacity(0.7), in: Capsule())
            }

            Text(entry.name)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)

            HStack(spacing: 10) {
                Image(systemName: metadata.symbol)
                    .foregroundStyle(Color.ocean)
                VStack(alignment: .leading, spacing: 2) {
                    Text(metadata.label.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(.secondary)
                    Text(metadata.value)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ink)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 8)
    }

    private var recommendationCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: recommendationSymbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(recommendationColor)
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.72), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("RECOMMENDATION")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(recommendationColor)
                Text(recommendation)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(recommendationColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var whatToKnowCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if horizontalSizeClass == .regular {
                Label("What to know", systemImage: "lightbulb.max.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ink)
            } else {
                Text("What to know")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ink)
            }
            Text(entry.description)
                .font(.body)
                .foregroundStyle(Color.ink.opacity(0.84))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(horizontalSizeClass == .regular ? 22 : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if horizontalSizeClass == .regular {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.84))
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: addToShoppingList) {
                Label(addToListState.title, systemImage: addToListState.symbol)
                    .frame(maxWidth: .infinity)
            }
            .disabled(addToListState != .idle)
            .contextMenu {
                Button("Choose Different List", systemImage: "list.bullet") {
                    chooseShoppingList()
                }
            }

            Group {
                if let shareImage {
                    ShareLink(
                        item: shareImage,
                        subject: Text("Seafood Guide: \(entry.name)"),
                        message: Text("Explore \(entry.name) with Seafood Guide."),
                        preview: SharePreview(
                            "\(entry.name) • Seafood Guide",
                            image: shareImage.previewImage
                        )
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    Label("Preparing", systemImage: "photo.badge.arrow.down")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var metadata: (label: String, value: String, symbol: String) {
        let components = entry.region.split(separator: ":", maxSplits: 1).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if components.count == 2 {
            let label = components[0]
            let symbol = label.localizedCaseInsensitiveCompare("Region") == .orderedSame
                ? "globe.americas.fill"
                : "tag.fill"
            return (label, components[1], symbol)
        }

        return ("Classification", entry.region, "tag.fill")
    }

    private var recommendation: String {
        entry.advice.replacingOccurrences(of: "Advice:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var recommendationColor: Color {
        if entry.status == "best" { return .green }
        if entry.status == "good" || entry.status == "check" { return .orange }
        if entry.status == "avoid" { return .red }
        let value = recommendation.lowercased()
        if value.contains("avoid") || value.contains("unsafe") { return .red }
        if value.contains("not ideal") || value.contains("mercury") || value.contains("sustainable choice") || value.contains("sustanable choice") { return .orange }
        if value.contains("safe to eat") { return .green }
        return .orange
    }

    private var recommendationSymbol: String {
        if entry.status == "best" { return "checkmark.seal.fill" }
        if entry.status == "good" || entry.status == "check" { return "exclamationmark.circle.fill" }
        if entry.status == "avoid" { return "exclamationmark.triangle.fill" }
        let value = recommendation.lowercased()
        if value.contains("avoid") || value.contains("unsafe") { return "exclamationmark.triangle.fill" }
        if value.contains("not ideal") || value.contains("mercury") || value.contains("sustainable choice") || value.contains("sustanable choice") { return "exclamationmark.circle.fill" }
        if value.contains("safe to eat") { return "checkmark.seal.fill" }
        return "exclamationmark.circle.fill"
    }

    private var reminderErrorBinding: Binding<Bool> {
        Binding(
            get: { reminderErrorMessage != nil },
            set: { if !$0 { reminderErrorMessage = nil } }
        )
    }

    private func addToShoppingList() {
        addToListState = .working
        Task {
            guard await reminderStore.requestAccess() else {
                addToListState = .idle
                showingRemindersPermissionAlert = true
                return
            }

            if let list = reminderStore.list(withIdentifier: shoppingListIdentifier) {
                add(entry, to: list)
            } else {
                addToListState = .idle
                showingListPicker = true
            }
        }
    }

    private func chooseShoppingList() {
        Task {
            guard await reminderStore.requestAccess() else {
                showingRemindersPermissionAlert = true
                return
            }
            showingListPicker = true
        }
    }

    private func add(_ entry: SeafoodEntry, to list: EKCalendar) {
        do {
            try reminderStore.add(entry, recommendation: recommendation, to: list)
            addToListState = .added
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                addToListState = .idle
            }
        } catch {
            addToListState = .idle
            reminderErrorMessage = error.localizedDescription
        }
    }

    private func renderShareImage() -> SeafoodShareImage? {
        let category = SeafoodCategory(rawValue: entry.categoryIndex) ?? .other
        let card = SeafoodShareCard(
            name: entry.name,
            metadataLabel: metadata.label,
            metadataValue: metadata.value,
            recommendation: recommendation,
            recommendationColor: recommendationColor,
            recommendationSymbol: recommendationSymbol,
            description: entry.description
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = 1

        let previewRenderer = ImageRenderer(content: SeafoodSharePreviewIcon(category: category))
        previewRenderer.scale = 1

        guard let data = renderer.uiImage?.pngData(),
              let previewData = previewRenderer.uiImage?.pngData() else { return nil }
        let safeName = entry.name
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
        return SeafoodShareImage(
            data: data,
            previewData: previewData,
            filename: "Seafood-Guide-\(safeName).png"
        )
    }
}

private struct RelatedSeafoodCard: View {
    let entry: SeafoodEntry

    private var category: SeafoodCategory {
        SeafoodCategory(rawValue: entry.categoryIndex) ?? .other
    }

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: category.symbolName)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.ocean)
                .frame(width: 46, height: 46)
                .background(category.tintColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(entry.name)
                    .font(.headline)
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)
                SeafoodGuidanceBadge(status: entry.status)
            }

            Spacer(minLength: 6)
            CardChevron()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private enum AddToListState {
    case idle, working, added

    var title: String {
        switch self {
        case .idle: "Add to List"
        case .working: "Adding"
        case .added: "Added"
        }
    }

    var symbol: String {
        switch self {
        case .idle: "cart.badge.plus"
        case .working: "ellipsis"
        case .added: "checkmark"
        }
    }
}

@MainActor
private final class SeafoodReminderStore: ObservableObject {
    private let eventStore = EKEventStore()
    @Published private(set) var lists: [EKCalendar] = []

    func requestAccess() async -> Bool {
        let granted = await withCheckedContinuation { continuation in
            eventStore.requestFullAccessToReminders { granted, _ in
                continuation.resume(returning: granted)
            }
        }

        if granted {
            lists = eventStore.calendars(for: .reminder)
                .filter(\.allowsContentModifications)
                .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
        return granted
    }

    func list(withIdentifier identifier: String) -> EKCalendar? {
        lists.first { $0.calendarIdentifier == identifier }
    }

    func add(_ entry: SeafoodEntry, recommendation: String, to list: EKCalendar) throws {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = list
        reminder.title = entry.name

        var noteLines = [
            "Added from Seafood Guide",
            recommendation,
            entry.region
        ].filter { !$0.isEmpty }

        if let source = entry.sources.first {
            noteLines.append("Source: \(source.title)")
            noteLines.append(source.url.absoluteString)
        }

        reminder.notes = noteLines.joined(separator: "\n")
        try eventStore.save(reminder, commit: true)
    }
}

private struct ReminderListPicker: View {
    let lists: [EKCalendar]
    let selection: (EKCalendar) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if lists.isEmpty {
                    ContentUnavailableView(
                        "No Editable Lists",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Create a list in Reminders, then try again.")
                    )
                } else {
                    List(lists, id: \.calendarIdentifier) { list in
                        Button {
                            selection(list)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "list.bullet")
                                    .font(.headline)
                                    .foregroundStyle(Color.ocean)
                                    .frame(width: 42, height: 42)
                                    .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                Text(list.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.ink)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Color.ocean)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Choose a List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct SeafoodShareImage: Transferable {
    let data: Data
    let previewData: Data
    let filename: String

    var previewImage: Image {
        if let image = UIImage(data: previewData) {
            return Image(uiImage: image)
        }
        return Image(systemName: "fish.fill")
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { image in
            image.data
        }
        .suggestedFileName { image in
            image.filename
        }
    }
}

private struct SeafoodSharePreviewIcon: View {
    let category: SeafoodCategory

    var body: some View {
        ZStack {
            category.tintColor

            Image(systemName: category.symbolName)
                .font(.system(size: 92, weight: .semibold))
                .foregroundStyle(Color.ocean)
        }
        .frame(width: 256, height: 256)
    }
}

struct SeafoodShareCard: View {
    let name: String
    let metadataLabel: String
    let metadataValue: String
    let recommendation: String
    let recommendationColor: Color
    let recommendationSymbol: String
    let description: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.appBackground, .sky.opacity(0.75), .seafoam.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.sunshine.opacity(0.45))
                .frame(width: 420, height: 420)
                .offset(x: 420, y: -430)

            Circle()
                .fill(Color.coral.opacity(0.32))
                .frame(width: 360, height: 360)
                .offset(x: -470, y: 470)

            VStack(alignment: .leading, spacing: 44) {
                HStack(spacing: 22) {
                    Image(systemName: "fish.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(Color.ocean)
                        .frame(width: 92, height: 92)
                        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("SEAFOOD GUIDE")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .tracking(3)
                            .foregroundStyle(Color.ocean)
                        Text("Choose seafood with confidence")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.ink.opacity(0.68))
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 22) {
                    Text(metadataLabel.uppercased())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Color.ocean)
                    Text(metadataValue)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ink.opacity(0.72))
                    Text(name)
                        .font(.system(size: 76, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)
                        .minimumScaleFactor(0.68)
                        .lineLimit(2)
                }

                HStack(spacing: 24) {
                    Image(systemName: recommendationSymbol)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(recommendationColor)
                        .frame(width: 78, height: 78)
                        .background(.white.opacity(0.76), in: Circle())

                    VStack(alignment: .leading, spacing: 7) {
                        Text("RECOMMENDATION")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(recommendationColor)
                        Text(recommendation)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)
                            .lineLimit(2)
                    }
                }
                .padding(30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(recommendationColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 34, style: .continuous))

                Text(description)
                    .font(.system(size: 27, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.ink.opacity(0.76))
                    .lineSpacing(8)
                    .lineLimit(5)

                Spacer(minLength: 0)

                HStack {
                    Text("Explore more in Seafood Guide")
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ocean)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Color.ocean)
                }
            }
            .padding(72)
        }
        .frame(width: 1080, height: 1080)
    }
}

enum ArticlePresentation {
    case reference
    case risks
}

struct ArticleListView: View {
    let title: String
    let articles: [GuideArticle]
    let presentation: ArticlePresentation
    @State private var query = ""
    @State private var articleCardHeight: CGFloat = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(title: String, articles: [GuideArticle], presentation: ArticlePresentation = .reference) {
        self.title = title
        self.articles = articles
        self.presentation = presentation
    }

    private var filtered: [GuideArticle] {
        guard !query.isEmpty else { return articles }
        return articles.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.body.localizedCaseInsensitiveContains(query) }
    }

    private var introduction: String {
        switch presentation {
        case .reference:
            "Plain-language definitions for labels, fishing methods, habitats, and seafood sourcing."
        case .risks:
            "Aquaculture is not one system. Explore the environmental, animal-health, food-safety, and community factors that can vary by farm."
        }
    }

    private var headerSymbol: String {
        presentation == .risks ? "exclamationmark.shield.fill" : "text.book.closed.fill"
    }

    private var headerColor: Color {
        presentation == .risks ? .coral : .sky
    }

    private let columns = [GridItem(.adaptive(minimum: 300, maximum: 520), spacing: 14)]

    var body: some View {
        ZStack {
            OceanBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .top, spacing: 18) {
                        Image(systemName: headerSymbol)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color.ocean)
                            .frame(width: 62, height: 62)
                            .background(headerColor, in: RoundedRectangle(cornerRadius: 19, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(articles.count) topics")
                                .font(.caption.weight(.bold))
                                .tracking(1.1)
                                .foregroundStyle(Color.ocean)
                            Text(introduction)
                                .font(.title3)
                                .foregroundStyle(Color.ink.opacity(0.72))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                        ForEach(filtered) { article in
                            NavigationLink {
                                ArticleDetailView(
                                    article: article,
                                    presentation: presentation,
                                    relatedArticles: articles
                                )
                            } label: {
                                ArticleCard(
                                    article: article,
                                    presentation: presentation,
                                    sharedHeight: horizontalSizeClass == .regular ? articleCardHeight : 0
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onPreferenceChange(ArticleCardHeightKey.self) { measuredHeight in
                        if horizontalSizeClass == .regular {
                            articleCardHeight = measuredHeight
                        }
                    }
                }
                .frame(maxWidth: 1180)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle(title)
        .searchable(text: $query, prompt: presentation == .risks ? "Search risks" : "Search glossary")
    }
}

private struct ArticleCard: View {
    let article: GuideArticle
    let presentation: ArticlePresentation
    let sharedHeight: CGFloat

    private var symbol: String {
        articleSymbol(for: article.title, presentation: presentation)
    }

    private var color: Color {
        if presentation == .reference { return .seafoam }
        let palette: [Color] = [.coral, .sunshine, .sky, .lavender, .sand, .seafoam]
        return palette[(article.number ?? article.title.count) % palette.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Image(systemName: symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.ocean)
                    .frame(width: 50, height: 50)
                    .background(color, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                Spacer()
                CardChevron()
            }

            Text(article.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(article.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(17)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ArticleCardHeightKey.self,
                    value: proxy.size.height
                )
            }
        }
        .frame(maxWidth: .infinity, minHeight: max(190, sharedHeight), alignment: .topLeading)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.055), radius: 9, y: 4)
    }
}

private struct ArticleCardHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private func articleSymbol(for title: String, presentation: ArticlePresentation) -> String {
    let value = title.lowercased()
    let matches: [(String, String)] = [
        ("habitat", "water.waves"), ("waste", "drop.triangle.fill"),
        ("escape", "figure.run"), ("disease", "cross.case.fill"),
        ("parasite", "allergens.fill"), ("feed", "leaf.fill"),
        ("wildlife", "bird.fill"), ("medicine", "pills.fill"),
        ("chemical", "testtube.2"), ("weather", "cloud.bolt.rain.fill"),
        ("climate", "thermometer.high"), ("ocean", "sailboat.fill"),
        ("oversight", "checkmark.seal.fill"), ("biosecurity", "shield.lefthalf.filled"),
        ("food safety", "fork.knife"), ("welfare", "heart.fill"),
        ("community", "person.3.fill"), ("water", "drop.fill"),
        ("label", "tag.fill"), ("stock", "chart.line.uptrend.xyaxis"),
        ("trawl", "water.waves.and.arrow.trianglehead.down"), ("line", "point.topleft.down.to.point.bottomright.curvepath"),
        ("net", "circle.grid.cross.fill"), ("farm", "building.2.crop.circle.fill")
    ]
    return matches.first(where: { value.contains($0.0) })?.1
        ?? (presentation == .risks ? "exclamationmark.shield.fill" : "text.book.closed.fill")
}

struct ArticleDetailView: View {
    let article: GuideArticle
    let presentation: ArticlePresentation
    let relatedArticles: [GuideArticle]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(
        article: GuideArticle,
        presentation: ArticlePresentation = .reference,
        relatedArticles: [GuideArticle] = []
    ) {
        self.article = article
        self.presentation = presentation
        self.relatedArticles = relatedArticles
    }

    private var related: [GuideArticle] {
        let currentNumber = article.number ?? 0
        return Array(
            relatedArticles
                .filter { $0.id != article.id }
                .sorted {
                    abs(($0.number ?? 0) - currentNumber) < abs(($1.number ?? 0) - currentNumber)
                }
                .prefix(5)
        )
    }

    var body: some View {
        ScrollView {
            if horizontalSizeClass == .regular {
                tabletContent
            } else {
                compactContent
            }
        }
        .background(OceanBackground())
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            articleHero
            Text(article.title).font(.system(size: 32, weight: .bold, design: .rounded))
            Text(article.body).font(.body).lineSpacing(5)
            SourceLinksView(sources: article.sources)
        }
        .padding()
    }

    private var tabletContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 20) {
                Image(systemName: articleSymbol(for: article.title, presentation: presentation))
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.ocean)
                    .frame(width: 82, height: 82)
                    .background(articleColor, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack(alignment: .leading, spacing: 7) {
                    Text(presentation == .risks ? "SEAFOOD RISK" : "GUIDE REFERENCE")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(Color.ocean)
                    Text(article.title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)
                }

                Spacer(minLength: 0)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(articleColor.opacity(0.72), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    Label("What to know", systemImage: "lightbulb.max.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.ink)
                    Text(article.body)
                        .font(.title3)
                        .foregroundStyle(Color.ink.opacity(0.78))
                        .lineSpacing(7)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

                SourceLinksView(sources: article.sources)
            }

            if !related.isEmpty {
                RelatedArticlesView(
                    articles: related,
                    allArticles: relatedArticles,
                    presentation: presentation
                )
            }
        }
        .frame(maxWidth: 1180)
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
    }

    private var articleHero: some View {
        Image(systemName: articleSymbol(for: article.title, presentation: presentation))
            .font(.system(size: 42, weight: .semibold))
            .foregroundStyle(Color.ocean)
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(articleColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var articleColor: Color {
        presentation == .risks ? Color.coral.opacity(0.6) : Color.seafoam
    }
}

private struct RelatedArticlesView: View {
    let articles: [GuideArticle]
    let allArticles: [GuideArticle]
    let presentation: ArticlePresentation

    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related topics")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.ink)

            Text("Continue through the guide without returning to the full list.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(articles) { relatedArticle in
                    NavigationLink {
                        ArticleDetailView(
                            article: relatedArticle,
                            presentation: presentation,
                            relatedArticles: allArticles
                        )
                    } label: {
                        HStack(spacing: 13) {
                            Image(systemName: articleSymbol(for: relatedArticle.title, presentation: presentation))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color.ocean)
                                .frame(width: 46, height: 46)
                                .background(
                                    presentation == .risks ? Color.coral.opacity(0.55) : Color.seafoam,
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                )

                            Text(relatedArticle.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color.ink)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: 8)
                            CardChevron()
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

struct SourceLinksView: View {
    let sources: [GuideSource]

    var body: some View {
        if !sources.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("Sources", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(Color.ink)

                ForEach(sources) { source in
                    Link(destination: source.url) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.right.square.fill")
                                .foregroundStyle(Color.ocean)
                            Text(source.title)
                                .font(.subheadline.weight(.semibold))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                        }
                        .foregroundStyle(Color.ink)
                        .padding(14)
                        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    let sections: [GuideSection]
    @State private var articleCardHeight: CGFloat = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let columns = [GridItem(.adaptive(minimum: 300, maximum: 520), spacing: 14)]

    var body: some View {
        ZStack {
            OceanBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack(alignment: .top, spacing: 18) {
                        Image(systemName: "info.bubble.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color.ocean)
                            .frame(width: 62, height: 62)
                            .background(Color.lavender, in: RoundedRectangle(cornerRadius: 19, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("ABOUT THE GUIDE")
                                .font(.caption.weight(.bold))
                                .tracking(1.2)
                                .foregroundStyle(Color.ocean)
                            Text("Make the guide work for you.")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color.ink)
                            Text("Understand the recommendations, ask better questions, and know where the information comes from.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

                    ForEach(Array(sections.enumerated()), id: \.element.id) { sectionIndex, section in
                        VStack(alignment: .leading, spacing: 14) {
                            Text(section.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color.ink)

                            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                                ForEach(section.articles) { article in
                                    NavigationLink {
                                        ArticleDetailView(article: article, relatedArticles: section.articles)
                                    } label: {
                                        AboutArticleCard(
                                            article: article,
                                            colorIndex: sectionIndex,
                                            sharedHeight: horizontalSizeClass == .regular ? articleCardHeight : 0
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label("A guide, not a local advisory", systemImage: "location.magnifyingglass")
                            .font(.headline)
                            .foregroundStyle(Color.ink)
                        Text("Seafood Guide explains terminology, species information, sustainability considerations, and sourcing practices. Check current local advisories before making consumption decisions.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.sunshine.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .onPreferenceChange(AboutArticleCardHeightKey.self) { measuredHeight in
                    if horizontalSizeClass == .regular {
                        articleCardHeight = measuredHeight
                    }
                }
                .frame(maxWidth: 1180)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("About")
    }
}

private struct AboutArticleCard: View {
    let article: GuideArticle
    let colorIndex: Int
    let sharedHeight: CGFloat

    private var color: Color {
        [Color.seafoam, .sky, .lavender, .sunshine][colorIndex % 4]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Image(systemName: articleSymbol(for: article.title, presentation: .reference))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.ocean)
                    .frame(width: 50, height: 50)
                    .background(color, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                Spacer()
                CardChevron()
            }

            Text(article.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(article.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(17)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: AboutArticleCardHeightKey.self,
                    value: proxy.size.height
                )
            }
        }
        .frame(maxWidth: .infinity, minHeight: max(190, sharedHeight), alignment: .topLeading)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.055), radius: 9, y: 4)
    }
}

private struct AboutArticleCardHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
