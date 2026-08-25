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
            .tint(.ocean)
            .task {
                try? await Task.sleep(nanoseconds: 650_000_000)
                withAnimation(.easeInOut(duration: 0.35)) { isLoaded = true }
            }
        }
    }
}

struct LaunchView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            OceanBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.ocean.opacity(0.22))
                            .frame(width: 150, height: 12)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.ink.opacity(0.16))
                            .frame(maxWidth: 280, minHeight: 34)
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.ink.opacity(0.10))
                            .frame(maxWidth: 330, minHeight: 20)
                    }
                    .padding(.horizontal, 20)

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.seafoam.opacity(0.82))
                        .frame(maxWidth: .infinity, minHeight: 178)
                        .overlay {
                            Image(systemName: "fish.fill")
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundStyle(Color.ocean.opacity(0.45))
                                .scaleEffect(isAnimating ? 1.06 : 0.94)
                        }
                        .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.ink.opacity(0.12))
                            .frame(width: 170, height: 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(0..<3, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill([Color.coral, Color.sunshine, Color.lavender][index].opacity(0.45))
                                        .frame(width: 150, height: 132)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal, 20)

                    ProgressView()
                        .tint(.ocean)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)
                }
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 28)
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { isAnimating = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading seafood guide")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
