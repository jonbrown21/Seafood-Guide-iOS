import SwiftUI

extension Color {
    static let ocean = Color(red: 0.04, green: 0.35, blue: 0.47)
    static let appBackground = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let seafoam = Color(red: 0.78, green: 0.95, blue: 0.91)
    static let sky = Color(red: 0.80, green: 0.91, blue: 1.0)
    static let coral = Color(red: 1.0, green: 0.70, blue: 0.62)
    static let sunshine = Color(red: 1.0, green: 0.88, blue: 0.40)
    static let lavender = Color(red: 0.88, green: 0.83, blue: 1.0)
    static let ink = Color(red: 0.06, green: 0.11, blue: 0.18)
    static let sand = Color(red: 1.0, green: 0.98, blue: 0.91)
}

struct OceanBackground: View {
    var body: some View {
        LinearGradient(colors: [.appBackground, .sky.opacity(0.35), .sand.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
