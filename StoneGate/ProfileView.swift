import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @State private var biometricsEnabled: Bool = true

    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 52)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileHeader
                        accountSection
                        settingsSection
                        supportSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var topBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.backward")
                    .font(.title3)
                    .foregroundColor(theme.primaryText)
            }

            Spacer()

            Text("Профиль")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)

            Spacer()

            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(theme.primaryText)
            }
        }
        .frame(height: 44)
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=200&q=80")) { phase in
                switch phase {
                case .empty:
                        Circle()
                            .fill(theme.secondaryBackground)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(.circular)
                            )
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Circle()
                        .fill(theme.secondaryBackground)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(theme.secondaryText)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 106, height: 106)
            .clipShape(Circle())
            .overlay(Circle().stroke(theme.secondaryText.opacity(0.4), lineWidth: 2))

            Text("Роман Юрченко")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)

            Text("romanyurchenko@gmail.com")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(theme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Аккаунт")
            ProfileRow(icon: "person.crop.circle", title: "Личные данные")
            ProfileRow(icon: "lock", title: "Безопасность")
            ProfileRow(icon: "checkmark.seal.fill",
                       title: "Верификация",
                       trailingText: "Подтверждён",
                       trailingColor: .green)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(20)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Настройки")
            ProfileRow(icon: "bell", title: "Уведомления")
            ToggleRow(icon: "touchid", title: "Биометрический вход", isOn: $biometricsEnabled)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(20)
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Поддержка")
            ProfileRow(icon: "questionmark.circle", title: "Помощь и поддержка")
            ProfileRow(icon: "info.circle", title: "О приложении")
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(20)
    }
}

private struct ProfileRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    var trailingText: String? = nil
    var trailingColor: Color? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(theme.primaryText)
                .frame(width: 32, height: 32)

            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(theme.primaryText)

            Spacer()

            if let trailingText {
                Text(trailingText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(trailingColor ?? theme.accentColor)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(theme.secondaryText)
        }
        .padding(.vertical, 6)
    }
}

private struct ToggleRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(theme.primaryText)
                .frame(width: 32, height: 32)

            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(theme.primaryText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: theme.toggleTint))
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProfileView()
}
