import SwiftUI

@main
struct SeafoodGuideApp: App {
    @StateObject private var store = GuideStore()
    @State private var isLoaded = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoaded {
                    GuideRootView(store: store)
                } else {
                    LaunchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tint(.ocean)
            .task {
                try? await Task.sleep(nanoseconds: 650_000_000)
                withAnimation(.easeInOut(duration: 0.35)) { isLoaded = true }
            }
        }
    }
}

struct LaunchView: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            OceanBackground()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.72))
                        .frame(width: 132, height: 132)
                        .scaleEffect(isPulsing ? 1.08 : 0.94)
                        .opacity(isPulsing ? 0.55 : 0.9)
                    Image(systemName: "fish.fill")
                        .font(.system(size: 58, weight: .semibold))
                        .foregroundStyle(Color.ocean)
                }
                Text("Seafood Guide")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                ProgressView("Preparing your guide")
                    .tint(.ocean)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
        }
        .task {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { isPulsing = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Seafood Guide is loading")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
