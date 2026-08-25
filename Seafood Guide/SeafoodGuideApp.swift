import SwiftUI

@main
struct SeafoodGuideApp: App {
    @StateObject private var store = GuideStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if store.isLoaded {
                    GuideRootView(store: store)
                        .transition(.opacity)
                } else {
                    LaunchView()
                        .transition(.opacity)
                }
            }
            .tint(.ocean)
            .task {
                await store.load()
            }
            .animation(.easeOut(duration: 0.2), value: store.isLoaded)
        }
    }
}

struct LaunchView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            OceanBackground()
            ScrollView {
                if horizontalSizeClass == .regular {
                    TabletLaunchPlaceholder()
                } else {
                    CompactLaunchPlaceholder()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading seafood guide")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CompactLaunchPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            SkeletonHeading()

            SkeletonHero(color: .seafoam)

            VStack(alignment: .leading, spacing: 14) {
                SkeletonLine(width: 190, height: 22, opacity: 0.14)
                SkeletonCategoryCard(color: .sunshine)
            }

            VStack(alignment: .leading, spacing: 14) {
                SkeletonLine(width: 180, height: 22, opacity: 0.14)
                HStack(spacing: 12) {
                    SkeletonShortcut(color: .sky)
                    SkeletonShortcut(color: .coral)
                }
            }
        }
        .frame(maxWidth: 920)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
    }
}

private struct TabletLaunchPlaceholder: View {
    private let columns = [GridItem(.adaptive(minimum: 230, maximum: 320), spacing: 16)]
    private let colors: [Color] = [.seafoam, .coral, .sunshine, .sky, .lavender, .sand, .coral, .seafoam]

    var body: some View {
        VStack(alignment: .leading, spacing: 34) {
            HStack(alignment: .bottom) {
                SkeletonHeading()
                Spacer()
                Capsule()
                    .fill(.white.opacity(0.82))
                    .frame(width: 170, height: 40)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                SkeletonHero(color: .seafoam)
                SkeletonHero(color: .white)
            }

            VStack(alignment: .leading, spacing: 16) {
                SkeletonLine(width: 190, height: 26, opacity: 0.14)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(colors.indices, id: \.self) { index in
                        SkeletonTabletCategory(color: colors[index])
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SkeletonLine(width: 220, height: 26, opacity: 0.14)
                HStack(spacing: 12) {
                    SkeletonShortcut(color: .sky)
                    SkeletonShortcut(color: .coral)
                }
            }
        }
        .frame(maxWidth: 1280)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.vertical, 36)
    }
}

private struct SkeletonHeading: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SkeletonLine(width: 150, height: 12, opacity: 0.22)
            SkeletonLine(width: 360, height: 38, opacity: 0.16)
            SkeletonLine(width: 430, height: 20, opacity: 0.10)
        }
    }
}

private struct SkeletonHero: View {
    let color: Color

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 11) {
                SkeletonLine(width: 220, height: 28, opacity: 0.14)
                SkeletonLine(width: 280, height: 16, opacity: 0.10)
                SkeletonLine(width: 150, height: 16, opacity: 0.16)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ocean.opacity(0.12))
                .frame(width: 82, height: 82)
        }
        .padding(24)
        .background(color.opacity(0.82), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct SkeletonCategoryCard: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(0.72))
                .aspectRatio(2.5, contentMode: .fit)
            SkeletonLine(width: 150, height: 20, opacity: 0.14)
            SkeletonLine(width: 240, height: 14, opacity: 0.09)
        }
        .padding(10)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct SkeletonTabletCategory: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(color.opacity(0.72))
                    .frame(width: 62, height: 62)
                Spacer()
                SkeletonLine(width: 30, height: 24, opacity: 0.14)
            }
            SkeletonLine(width: 130, height: 20, opacity: 0.14)
            SkeletonLine(height: 14, opacity: 0.09)
        }
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct SkeletonShortcut: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.72))
                .frame(width: 46, height: 46)
            SkeletonLine(width: 130, height: 18, opacity: 0.14)
            SkeletonLine(height: 13, opacity: 0.09)
            SkeletonLine(width: 120, height: 13, opacity: 0.09)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct SkeletonLine: View {
    var width: CGFloat? = nil
    let height: CGFloat
    let opacity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: min(height / 2, 8), style: .continuous)
            .fill(Color.ink.opacity(opacity))
            .frame(maxWidth: width == nil ? .infinity : nil)
            .frame(width: width, height: height)
    }
}
