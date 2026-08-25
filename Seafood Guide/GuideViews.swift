import SwiftUI

struct GuideRootView: View {
    @ObservedObject var store: GuideStore

    var body: some View {
        TabView {
            NavigationStack { ExploreView(store: store) }
                .tabItem { Label("Explore", systemImage: "fish.fill") }
            NavigationStack { ArticleListView(title: "Seafood glossary", articles: store.glossary) }
                .tabItem { Label("Glossary", systemImage: "text.book.closed.fill") }
            NavigationStack { ArticleListView(title: "Top 10", articles: store.topTen) }
                .tabItem { Label("Top 10", systemImage: "number.circle.fill") }
            NavigationStack { AboutView(sections: store.aboutSections) }
                .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
        .preferredColorScheme(.light)
    }
}

struct ExploreView: View {
    @ObservedObject var store: GuideStore
    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 16)]

    var body: some View {
        ZStack {
            OceanBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Seafood Guide")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                        Text("Know what’s on your plate.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(SeafoodCategory.allCases) { category in
                            NavigationLink {
                                SeafoodListView(category: category, store: store)
                            } label: {
                                CategoryCard(category: category, count: store.seafood(in: category).count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

struct CategoryCard: View {
    let category: SeafoodCategory
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: category.symbolName)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(Color.ocean)
                .frame(maxWidth: .infinity)
                .frame(height: 116)
                .background(Color.seafoam, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text(category.title).font(.headline).foregroundStyle(Color.ink)
            Text("\(count) entries · \(category.subtitle)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(10)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
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
                    if let imageName = article.imageName { Image(imageName).resizable().scaledToFill().frame(width: 58, height: 58).clipShape(RoundedRectangle(cornerRadius: 12)) }
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
                if let imageName = article.imageName { Image(imageName).resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 210).clipped().clipShape(RoundedRectangle(cornerRadius: 20)) }
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
