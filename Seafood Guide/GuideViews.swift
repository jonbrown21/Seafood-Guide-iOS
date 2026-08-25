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
                            CategorySymbol(category: .all, size: 82)
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
            CategorySymbol(category: category, size: 104)
                .frame(maxWidth: .infinity)
            Text(category.title).font(.headline).foregroundStyle(Color.ink)
            Text(category.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(10)
        .frame(width: 190)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}

struct CategorySymbol: View {
    let category: SeafoodCategory
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .fill(category.tintColor)
            Image(systemName: category.symbolName)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundStyle(Color.ocean)
            Image(systemName: category.badgeSymbolName)
                .font(.system(size: size * 0.14, weight: .bold))
                .foregroundStyle(Color.ocean)
                .padding(size * 0.09)
                .background(.white.opacity(0.82), in: Circle())
                .offset(x: size * 0.30, y: -size * 0.28)
        }
        .frame(width: size, height: size)
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
        List {
            Section {
                Text(entry.name).font(.system(size: 32, weight: .bold, design: .rounded))
                Label(entry.region, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
            }
            Section("Advice") { Text(entry.advice) }
            Section("Description") { Text(entry.description).fixedSize(horizontal: false, vertical: true) }
            Section("Share") {
                ShareLink(item: shareText, subject: Text("Seafood Guide: \(entry.name)")) {
                    Label("Share this seafood", systemImage: "square.and.arrow.up")
                }
                Button { openURL(mailURL) } label: { Label("Email to a friend", systemImage: "envelope") }
            }
        }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var shareText: String { "\(entry.name)\n\n\(entry.region)\n\n\(entry.advice)\n\n\(entry.description)" }
    private var mailURL: URL { URL(string: "mailto:?subject=Seafood%20Guide:%20\(entry.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? entry.name)&body=\(shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? shareText)")! }
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
