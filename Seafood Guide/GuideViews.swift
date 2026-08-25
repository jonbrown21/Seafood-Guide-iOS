import SwiftUI

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
            Tab("Top 10", systemImage: "medal.fill") {
                NavigationStack { ArticleListView(title: "Top 10", articles: store.topTen) }
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

    var body: some View {
        ZStack {
            OceanBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
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
                    .padding(.horizontal, 20)

                    NavigationLink {
                        SeafoodListView(category: .all, store: store)
                    } label: {
                        HStack(spacing: 18) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Browse all seafood")
                                    .font(.title2.weight(.bold))
                                Text("Find a species or discover something new")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.ink.opacity(0.7))
                                Label("Open the guide", systemImage: "arrow.right.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.ocean)
                            }
                            Spacer(minLength: 8)
                            CategorySymbol(category: .all)
                                .frame(width: 82, height: 82)
                        }
                        .padding(22)
                        .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "sparkles")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.ocean.opacity(0.7))
                                .padding(18)
                        }
                    }
                    .buttonStyle(.plain)
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
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 14) {
                                ForEach(SeafoodCategory.allCases.filter { $0 != .all }) { category in
                                    NavigationLink {
                                        SeafoodListView(category: category, store: store)
                                    } label: {
                                        CategoryCard(category: category)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Learn before you buy")
                            .font(.title3.weight(.bold))

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
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
                                ArticleListView(title: "Top 10", articles: store.topTen)
                            } label: {
                                GuideShortcutCard(
                                    title: "Top 10 choices",
                                    subtitle: "See the guide’s featured seafood picks",
                                    symbol: "medal.fill",
                                    color: .sunshine
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 28)
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        .frame(width: 220)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
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

    private var filtered: [SeafoodEntry] {
        let entries = store.seafood(in: category)
        guard !query.isEmpty else { return entries }
        return entries.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.region.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List(filtered) { fish in
            NavigationLink { SeafoodDetailView(entry: fish) } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fish.name).font(.headline)
                    Text(fish.advice).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle(category.title)
        .searchable(text: $query, prompt: "Search seafood")
    }
}

struct SeafoodDetailView: View {
    let entry: SeafoodEntry
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            OceanBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "fish.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(Color.ocean)
                                .frame(width: 58, height: 58)
                                .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

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
                    .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 16, y: 8)

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
                    .background(recommendationColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What to know")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.ink)
                        Text(entry.description)
                            .font(.body)
                            .foregroundStyle(Color.ink.opacity(0.84))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 12) {
                        ShareLink(item: shareText, subject: Text("Seafood Guide: \(entry.name)")) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            if let mailURL { openURL(mailURL) }
                        } label: {
                            Label("Email", systemImage: "envelope.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(mailURL == nil)
                    }
                    .controlSize(.large)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
        }
        .navigationTitle("Seafood details")
        .navigationBarTitleDisplayMode(.inline)
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
        let value = recommendation.lowercased()
        if value.contains("avoid") || value.contains("unsafe") { return .red }
        if value.contains("not ideal") || value.contains("mercury") || value.contains("sustainable choice") || value.contains("sustanable choice") { return .orange }
        if value.contains("safe to eat") { return .green }
        return .orange
    }

    private var recommendationSymbol: String {
        let value = recommendation.lowercased()
        if value.contains("avoid") || value.contains("unsafe") { return "exclamationmark.triangle.fill" }
        if value.contains("not ideal") || value.contains("mercury") || value.contains("sustainable choice") || value.contains("sustanable choice") { return "exclamationmark.circle.fill" }
        if value.contains("safe to eat") { return "checkmark.seal.fill" }
        return "exclamationmark.circle.fill"
    }

    private var shareText: String { "\(entry.name)\n\n\(entry.region)\n\n\(entry.advice)\n\n\(entry.description)" }
    private var mailURL: URL? {
        URL(string: "mailto:?subject=Seafood%20Guide:%20\(entry.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? entry.name)&body=\(shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? shareText)")
    }
}

struct ArticleListView: View {
    let title: String
    let articles: [GuideArticle]
    @State private var query = ""

    private var filtered: [GuideArticle] {
        guard !query.isEmpty else { return articles }
        return articles.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.body.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List(filtered) { article in
            NavigationLink { ArticleDetailView(article: article) } label: {
                HStack(spacing: 14) {
                    Image(systemName: article.number == nil ? "book.pages.fill" : "number.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.ocean)
                        .frame(width: 42, height: 42)
                        .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        if let number = article.number { Text("\(number)").font(.caption.weight(.bold)).foregroundStyle(.teal) }
                        Text(article.title).font(.headline)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle(title)
        .searchable(text: $query, prompt: "Search articles")
    }
}

struct ArticleDetailView: View {
    let article: GuideArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: article.number == nil ? "book.pages.fill" : "text.book.closed.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Color.ocean)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(article.title).font(.system(size: 32, weight: .bold, design: .rounded))
                Text(article.body).font(.body).lineSpacing(5)
            }
            .padding()
        }
        .background(OceanBackground())
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    let sections: [GuideSection]

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(section.title) {
                    ForEach(section.articles) { article in
                        NavigationLink(article.title) { ArticleDetailView(article: article) }
                    }
                }
            }
            Section("About this app") {
                Text("Seafood Guide helps you learn seafood terminology, species information, sustainability considerations, and sourcing practices.")
                Text("Content is provided for educational purposes. Check current local advisories before making decisions about seafood consumption.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}
