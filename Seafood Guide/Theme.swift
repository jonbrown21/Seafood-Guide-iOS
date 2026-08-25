import SwiftUI

extension Color {
    static let ocean = Color(red: 0.04, green: 0.35, blue: 0.47)
    static let seafoam = Color(red: 0.83, green: 0.94, blue: 0.92)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.16)
    static let sand = Color(red: 0.97, green: 0.96, blue: 0.92)
}

struct OceanBackground: View {
    var body: some View {
        LinearGradient(colors: [.seafoam, .sand], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
