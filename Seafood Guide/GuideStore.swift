import Foundation
import Combine

@MainActor
final class GuideStore: ObservableObject {
    @Published private(set) var isLoaded = false
    @Published private(set) var seafood: [SeafoodEntry] = []
    @Published private(set) var glossary: [GuideArticle] = []
    @Published private(set) var aquacultureProblems: [GuideArticle] = []
    @Published private(set) var aboutSections: [GuideSection] = []

    func load() async {
        guard !isLoaded else { return }
        await Task.yield()

        seafood = SeafoodXMLParser.entries(named: "seafood")
        glossary = ResourceXMLParser.articles(named: "ios-lingo")
        aquacultureProblems = ResourceXMLParser.articles(named: "ios-news")
        aboutSections = Self.loadAboutSections()
        isLoaded = true
    }

    func seafood(in category: SeafoodCategory) -> [SeafoodEntry] {
        if category == .all { return seafood.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending } }
        return seafood.filter { $0.categoryIndex == category.rawValue }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func loadAboutSections() -> [GuideSection] {
        let articles = [
            ResourceXMLParser.articles(named: "ios-about-1"),
            ResourceXMLParser.articles(named: "ios-about-2"),
            ResourceXMLParser.articles(named: "ios-about-3")
        ].flatMap { $0 }
        let groups = Dictionary(grouping: articles) { article in article.number ?? 1 }
        let titles = [1: "About the Seafood Guide", 2: "What you can do", 3: "Labeling"]
        return [1, 2, 3].map { key in
            GuideSection(title: titles[key] ?? "", articles: groups[key] ?? [])
        }
    }
}

private final class SeafoodXMLParser: NSObject, XMLParserDelegate {
    private var parsedEntries: [SeafoodEntry] = []
    private var currentElement = ""
    private var insideEntry = false
    private var name = ""
    private var category = ""
    private var entryDescription = ""
    private var advice = ""
    private var detail = ""
    private var status = ""
    private var sources: [GuideSource] = []
    private var sourceTitle = ""
    private var sourceURL = ""

    static func entries(named name: String) -> [SeafoodEntry] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "xml"),
              let data = try? Data(contentsOf: url) else { return [] }
        let parser = SeafoodXMLParser()
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = parser
        xmlParser.parse()
        return parser.parsedEntries
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        if elementName == "entry" {
            insideEntry = true
            name = ""
            category = ""
            entryDescription = ""
            advice = ""
            detail = ""
            status = ""
            sources = []
        } else if elementName == "source" {
            sourceTitle = ""
            sourceURL = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideEntry else { return }
        switch currentElement {
        case "name": name += string
        case "category": category += string
        case "description": entryDescription += string
        case "advice": advice += string
        case "detail": detail += string
        case "status": status += string
        case "sourcetitle": sourceTitle += string
        case "sourceurl": sourceURL += string
        default: break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "source" {
            if let url = URL(string: sourceURL.cleaned), !sourceTitle.cleaned.isEmpty {
                sources.append(GuideSource(title: sourceTitle.cleaned, url: url))
            }
        } else if elementName == "entry" {
            if let parsedCategory = SeafoodCategory(xmlValue: category.cleaned) {
                parsedEntries.append(
                    SeafoodEntry(
                        name: name.cleaned,
                        categoryIndex: parsedCategory.rawValue,
                        description: entryDescription.cleaned,
                        advice: advice.cleaned,
                        region: detail.cleaned,
                        status: status.cleaned,
                        sources: sources
                    )
                )
            }
            insideEntry = false
        }
        currentElement = ""
    }
}

private final class ResourceXMLParser: NSObject, XMLParserDelegate {
    private var articles: [GuideArticle] = []
    private var currentTitle = ""
    private var currentBody = ""
    private var currentNumber: Int?
    private var currentSources: [GuideSource] = []
    private var currentSourceTitle = ""
    private var currentSourceURL = ""
    private var currentElement = ""
    private var insideArticle = false

    static func articles(named name: String) -> [GuideArticle] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "xml"), let data = try? Data(contentsOf: url) else { return [] }
        let parser = ResourceXMLParser()
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = parser
        xmlParser.parse()
        return parser.articles
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "new" {
            insideArticle = true
            currentTitle = ""
            currentBody = ""
            currentNumber = nil
            currentSources = []
        } else if elementName == "source" {
            currentSourceTitle = ""
            currentSourceURL = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideArticle else { return }
        switch currentElement {
        case "titlenews": currentTitle += string
        case "descnews": currentBody += string
        case "linknews":
            let value = string.trimmingCharacters(in: .whitespacesAndNewlines)
            currentNumber = Int(value)
        case "sourcetitle": currentSourceTitle += string
        case "sourceurl": currentSourceURL += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "source" {
            let title = currentSourceTitle.cleaned
            let urlString = currentSourceURL.cleaned
            if !title.isEmpty, let url = URL(string: urlString) {
                currentSources.append(GuideSource(title: title, url: url))
            }
        } else if elementName == "new" {
            articles.append(
                GuideArticle(
                    title: currentTitle.cleaned,
                    body: currentBody.cleaned,
                    number: currentNumber,
                    sources: currentSources
                )
            )
            insideArticle = false
        }
        currentElement = ""
    }
}

private extension String {
    var cleaned: String { replacingOccurrences(of: "\\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines) }
}
