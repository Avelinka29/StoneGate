import SwiftUI
import Combine

class Theme: ObservableObject {
    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode") {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    // MARK: - Background Colors
    var primaryBackground: Color {
        isDarkMode ? Color.black : Color.white
    }

    var secondaryBackground: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }

    var tertiaryBackground: Color {
        isDarkMode ? Color(red: 0.07, green: 0.07, blue: 0.09) : Color(red: 0.92, green: 0.92, blue: 0.94)
    }

    var cardBackground: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color.white
    }

    var tabBackground: Color {
        isDarkMode ? Color(red: 0.13, green: 0.13, blue: 0.15) : Color(red: 0.9, green: 0.9, blue: 0.92)
    }

    var inputBackground: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.97, green: 0.97, blue: 0.99)
    }

    // MARK: - Text Colors
    var primaryText: Color {
        isDarkMode ? .white : .black
    }

    var secondaryText: Color {
        isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }

    var tertiaryText: Color {
        isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
    }

    var quaternaryText: Color {
        isDarkMode ? Color.white.opacity(0.4) : Color.black.opacity(0.4)
    }

    var placeholderText: Color {
        isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.5)
    }

    // MARK: - Accent Colors
    var accentColor: Color {
        .green
    }

    var positiveColor: Color {
        .green
    }

    var negativeColor: Color {
        .red
    }

    var warningColor: Color {
        .orange
    }

    // MARK: - Border Colors
    var borderColor: Color {
        isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }

    var dividerColor: Color {
        isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }

    // MARK: - Chart Colors
    var chartFillGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(isDarkMode ? 0.45 : 0.6),
                Color.green.opacity(isDarkMode ? 0.02 : 0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var chartLineColor: Color {
        .green
    }

    // MARK: - Social Button Colors
    var googleButtonBackground: Color {
        .white
    }

    var googleButtonText: Color {
        .black
    }

    var yandexButtonBackground: Color {
        Color(red: 221/255, green: 55/255, blue: 55/255)
    }

    var yandexButtonText: Color {
        .white
    }

    var vkButtonBackground: Color {
        Color(red: 71/255, green: 107/255, blue: 197/255)
    }

    var vkButtonText: Color {
        .white
    }

    // MARK: - Toggle Colors
    var toggleTint: Color {
        .green
    }

    // MARK: - Shadow Colors
    var shadowColor: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
    }

    // MARK: - Opacity Values
    var lowOpacity: Double {
        0.1
    }

    var mediumOpacity: Double {
        0.4
    }

    var highOpacity: Double {
        0.7
    }
}

// MARK: - Environment Key
private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}