import SwiftUI

@main
struct SeafoodGuideApp: App {
    @StateObject private var store = GuideStore()

    var body: some Scene {
        WindowGroup {
            GuideRootView(store: store)
                .tint(.ocean)
        }
    }
}
