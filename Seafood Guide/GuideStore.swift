import Foundation
import Combine

@MainActor
final class GuideStore: ObservableObject {
    @Published private(set) var seafood: [SeafoodEntry] = SeafoodData.entries
    @Published private(set) var glossary: [GuideArticle] = []
    @Published private(set) var aquacultureProblems: [GuideArticle] = []
    @Published private(set) var aboutSections: [GuideSection] = []

    init() {
        glossary = ResourceXMLParser.articles(named: "ios-lingo")
        aquacultureProblems = ResourceXMLParser.articles(named: "ios-news")
        aboutSections = Self.loadAboutSections()
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

private final class ResourceXMLParser: NSObject, XMLParserDelegate {
    private var articles: [GuideArticle] = []
    private var currentTitle = ""
    private var currentBody = ""
    private var currentNumber: Int?
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
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "new" {
            articles.append(GuideArticle(title: currentTitle.cleaned, body: currentBody.cleaned, number: currentNumber))
            insideArticle = false
        }
        currentElement = ""
    }
}

private extension String {
    var cleaned: String { replacingOccurrences(of: "\\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines) }
}
