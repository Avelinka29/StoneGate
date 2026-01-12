import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var userProfile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showEditProfile = false

    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
            } else {
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
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadProfile()
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Произошла ошибка")
        }
        .sheet(isPresented: $showEditProfile) {
            if let profile = userProfile {
                EditProfileView(profile: profile) {
                    Task {
                        await loadProfile()
                    }
                }
                .environmentObject(themeManager)
                .environmentObject(authManager)
            }
        }
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
            // Аватар
            Group {
                if let avatarURL = userProfile?.avatar_url,
                   let url = URL(string: NetworkManager.shared.baseURL + avatarURL) {
                    AsyncImage(url: url) { phase in
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
                } else {
                    Circle()
                        .fill(theme.secondaryBackground)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(theme.secondaryText)
                        )
                }
            }
            .frame(width: 106, height: 106)
            .clipShape(Circle())
            .overlay(Circle().stroke(theme.secondaryText.opacity(0.4), lineWidth: 2))

            Text(userProfile?.name ?? "Пользователь")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)

            Text(userProfile?.email ?? "")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(theme.secondaryText)
            
            Button(action: {
                showEditProfile = true
            }) {
                Text("Редактировать профиль")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(theme.accentColor.opacity(0.1))
                    .cornerRadius(20)
            }
            .padding(.top, 4)
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
            Button(action: {
                showEditProfile = true
            }) {
                ProfileRow(icon: "person.crop.circle", title: "Личные данные")
            }
            ProfileRow(icon: "lock", title: "Безопасность")
            if let verified = userProfile?.verified {
                ProfileRow(icon: "checkmark.seal.fill",
                           title: "Верификация",
                           trailingText: verified ? "Подтверждён" : "Не подтверждён",
                           trailingColor: verified ? .green : .orange)
            }
            NavigationLink(destination: CardsListView()
                .environmentObject(authManager)
                .environmentObject(ThemeManager.shared)) {
                ProfileRow(icon: "creditcard", title: "Банковские карты")
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(20)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Настройки")
            if let profile = userProfile {
                ToggleRow(
                    icon: "bell",
                    title: "Уведомления",
                    isOn: Binding(
                        get: { profile.notifications_enabled },
                        set: { newValue in
                            Task {
                                await updateNotifications(newValue)
                            }
                        }
                    )
                )
                ToggleRow(
                    icon: "touchid",
                    title: "Биометрический вход",
                    isOn: Binding(
                        get: { profile.biometrics_enabled },
                        set: { newValue in
                            Task {
                                await updateBiometrics(newValue)
                            }
                        }
                    )
                )
            }
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
    
    // MARK: - Actions
    
    private func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile = try await NetworkManager.shared.getUserProfile()
            await MainActor.run {
                userProfile = profile
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
    
    private func updateNotifications(_ enabled: Bool) async {
        do {
            let settings = UserSettingsUpdate(notifications_enabled: enabled)
            let profile = try await NetworkManager.shared.updateUserSettings(settings)
            await MainActor.run {
                userProfile = profile
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func updateBiometrics(_ enabled: Bool) async {
        do {
            let settings = UserSettingsUpdate(biometrics_enabled: enabled)
            let profile = try await NetworkManager.shared.updateUserSettings(settings)
            await MainActor.run {
                userProfile = profile
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
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
        .environmentObject(ThemeManager.shared)
        .environmentObject(AuthManager())
}
