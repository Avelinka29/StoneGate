import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title3)
                            .foregroundColor(theme.primaryText)
                    }

                    Spacer()

                    Text("Настройки")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)

                    Spacer()

                    // Placeholder for symmetry
                    Image(systemName: "chevron.backward")
                        .font(.title3)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // App Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Приложение")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.secondaryText)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                SettingsRow(icon: "bell", title: "Уведомления", showChevron: true, iconColor: theme.primaryText, titleColor: theme.primaryText, trailingTextColor: theme.tertiaryText)
                                Divider()
                                    .background(theme.dividerColor)
                                    .padding(.leading, 60)
                                SettingsRow(icon: "moon", title: "Темная тема", toggleBinding: $themeManager.isDarkMode, iconColor: theme.primaryText, titleColor: theme.primaryText, trailingTextColor: theme.tertiaryText)
                                Divider()
                                    .background(theme.dividerColor)
                                    .padding(.leading, 60)
                                SettingsRow(icon: "globe", title: "Язык", showChevron: true, trailingText: "Русский", iconColor: theme.primaryText, titleColor: theme.primaryText, trailingTextColor: theme.tertiaryText)
                            }
                            .background(theme.cardBackground)
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }

                        // About Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("О приложении")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.secondaryText)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                SettingsRow(icon: "info.circle", title: "Версия", showChevron: false, trailingText: "1.0.0", iconColor: theme.primaryText, titleColor: theme.primaryText, trailingTextColor: theme.tertiaryText)
                                Divider()
                                    .background(theme.dividerColor)
                                    .padding(.leading, 60)
                                SettingsRow(icon: "doc.text", title: "Лицензия", showChevron: true, iconColor: theme.primaryText, titleColor: theme.primaryText, trailingTextColor: theme.tertiaryText)
                                Divider()
                                    .background(theme.dividerColor)
                                    .padding(.leading, 60)
                                SettingsRow(icon: "shield", title: "Политика конфиденциальности", showChevron: true, iconColor: theme.primaryText, titleColor: theme.primaryText, trailingTextColor: theme.tertiaryText)
                            }
                            .background(theme.cardBackground)
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }

                        // Logout Button
                        Button(action: {
                            authManager.logout()
                        }) {
                            Text("Выйти из аккаунта")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.secondaryBackground)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct SettingsRow: View {
    @Environment(\.theme) private var theme

    let icon: String
    let title: String
    var showChevron: Bool = false
    var toggleBinding: Binding<Bool>? = nil
    var trailingText: String? = nil
    var iconColor: Color? = nil
    var titleColor: Color? = nil
    var trailingTextColor: Color? = nil

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor ?? theme.primaryText)
                .frame(width: 24, height: 24)

            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(titleColor ?? theme.primaryText)

            Spacer()

            if let trailingText = trailingText {
                Text(trailingText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(trailingTextColor ?? theme.tertiaryText)
            }

            if let binding = toggleBinding {
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: theme.toggleTint))
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor((trailingTextColor ?? theme.tertiaryText).opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthManager())
    }
}

