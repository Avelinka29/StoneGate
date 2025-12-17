import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var biometricsEnabled: Bool = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

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
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Профиль")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(.white)
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
                        .fill(Color.gray.opacity(0.4))
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
                        .fill(Color.gray.opacity(0.4))
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 106, height: 106)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 2))

            Text("Роман Юрченко")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Text("romanyurchenko@gmail.com")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.65))
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
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(20)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Настройки")
            ProfileRow(icon: "bell", title: "Уведомления")
            ToggleRow(icon: "touchid", title: "Биометрический вход", isOn: $biometricsEnabled)
        }
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(20)
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Поддержка")
            ProfileRow(icon: "questionmark.circle", title: "Помощь и поддержка")
            ProfileRow(icon: "info.circle", title: "О приложении")
        }
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(20)
    }
}

private struct ProfileRow: View {
    let icon: String
    let title: String
    var trailingText: String? = nil
    var trailingColor: Color = .green

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)

            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            if let trailingText {
                Text(trailingText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(trailingColor)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)

            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color.green))
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProfileView()
}
