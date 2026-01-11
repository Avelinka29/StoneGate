import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.theme) private var theme
    @State private var selectedTab = 0
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var registerEmail = ""
    @State private var registerPassword = ""
    @State private var registerName = ""
    @State private var isButtonPressed = false
    @Namespace private var animation

    private let tabs = ["Вход", "Регистрация"]

    var body: some View {
        NavigationStack {
            ZStack {
                theme.primaryBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer(minLength: 12)

                    VStack(spacing: 8) {
                        Text("StoneGate")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)

                        Text("Умные финансы, безопасное инвестирование")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(theme.secondaryText)
                    }
                    .multilineTextAlignment(.center)

                    AuthTabBar(selectedTab: $selectedTab, animation: animation)

                    ZStack {
                        if selectedTab == 0 {
                            VStack(spacing: 18) {
                                VStack(spacing: 6) {
                                    Text("Email / Телефон")
                                        .font(.footnote)
                                        .foregroundColor(theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    AuthRoundedField(placeholder: "Введите ваш email или телефон",
                                                      text: $loginEmail,
                                                      keyboardType: .emailAddress)
                                }

                                VStack(spacing: 6) {
                                    Text("Пароль")
                                        .font(.footnote)
                                        .foregroundColor(theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    AuthRoundedField(placeholder: "Введите ваш пароль",
                                                      text: $loginPassword,
                                                      keyboardType: .default,
                                                      isSecure: true)
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                        } else {
                            VStack(spacing: 18) {
                                VStack(spacing: 6) {
                                    Text("Имя")
                                        .font(.footnote)
                                        .foregroundColor(theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    AuthRoundedField(placeholder: "Введите ваше имя",
                                                      text: $registerName)
                                }

                                VStack(spacing: 6) {
                                    Text("Email")
                                        .font(.footnote)
                                        .foregroundColor(theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    AuthRoundedField(placeholder: "Введите ваш email",
                                                      text: $registerEmail,
                                                      keyboardType: .emailAddress)
                                }

                                VStack(spacing: 6) {
                                    Text("Пароль")
                                        .font(.footnote)
                                        .foregroundColor(theme.secondaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    AuthRoundedField(placeholder: "Придумайте пароль",
                                                      text: $registerPassword,
                                                      keyboardType: .default,
                                                      isSecure: true)
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                    }
                    .animation(.spring(duration: 0.3), value: selectedTab)

                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()

                        Task {
                            if selectedTab == 0 {
                                await authManager.login(email: loginEmail, password: loginPassword)
                            } else {
                                await authManager.register(name: registerName,
                                                           email: registerEmail,
                                                           password: registerPassword,
                                                           phone: nil)
                            }
                        }
                    }) {
                        Group {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryBackground))
                            } else {
                                Text(selectedTab == 0 ? "Войти" : "Зарегистрироваться")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(theme.accentColor)
                        .foregroundColor(theme.primaryBackground)
                        .cornerRadius(18)
                        .scaleEffect(isButtonPressed ? 0.98 : 1.0)
                        .animation(.spring(duration: 0.1), value: isButtonPressed)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation(.spring(duration: 0.1)) {
                                    isButtonPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(duration: 0.1)) {
                                    isButtonPressed = false
                                }
                            }
                    )
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        .disabled(
                            authManager.isLoading ||
                                (selectedTab == 0
                                    ? loginEmail.isEmpty || loginPassword.isEmpty
                                    : registerEmail.isEmpty || registerPassword.isEmpty || registerName.isEmpty)
                        )

                    HStack(alignment: .center, spacing: 12) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(theme.dividerColor)

                        Text("Или войдите с помощью")
                            .font(.footnote)
                            .foregroundColor(theme.secondaryText)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(theme.dividerColor)
                    }

                    HStack(spacing: 24) {
                        SocialCircleButton(label: "G",
                                           backgroundColor: .white,
                                           textColor: .black,
                                           gradient: LinearGradient(
                                            colors: [
                                                Color(red: 66/255, green: 133/255, blue: 244/255),
                                                Color(red: 219/255, green: 68/255, blue: 55/255),
                                                Color(red: 244/255, green: 180/255, blue: 0),
                                                Color(red: 15/255, green: 157/255, blue: 88/255)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing)
                        ) {
                            Task { await authManager.socialLogin(provider: "google") }
                        }

                        SocialCircleButton(label: "Я",
                                           backgroundColor: Color(red: 221/255, green: 55/255, blue: 55/255),
                                           textColor: .white,
                                           gradient: nil) {
                            Task { await authManager.socialLogin(provider: "yandex") }
                        }

                        SocialCircleButton(label: "VK",
                                           backgroundColor: Color(red: 71/255, green: 107/255, blue: 197/255),
                                           textColor: .white,
                                           gradient: nil) {
                            Task { await authManager.socialLogin(provider: "vk") }
                        }
                    }

                    Text("Продолжая, вы соглашаетесь с нашими Условиями использования и Политикой конфиденциальности")
                        .font(.footnote)
                        .foregroundColor(theme.accentColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .navigationBarHidden(true)
            .alert("Ошибка", isPresented: .constant(!authManager.errorMessage.isEmpty)) {
                Button("OK") {
                    authManager.errorMessage = ""
                }
            } message: {
                Text(authManager.errorMessage)
            }
        }
    }
}

private struct AuthTabBar: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTab: Int
    let animation: Namespace.ID

    private let tabs = ["Вход", "Регистрация"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()

                    withAnimation(.spring(duration: 0.3)) {
                        selectedTab = index
                    }
                } label: {
                    Text(tabs[index])
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedTab == index ? theme.primaryText : theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedTab == index {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(theme.tertiaryBackground)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }
                        }
                        .cornerRadius(14)
                }
            }
        }
        .padding(6)
        .background(theme.tabBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.borderColor, lineWidth: 1)
        )
    }
}

private struct AuthRoundedField: View {
    @Environment(\.theme) private var theme
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(theme.placeholderText)
                    .font(.body)
            }

            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .keyboardType(keyboardType)
                } else {
                    TextField("", text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .foregroundColor(theme.primaryText)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(theme.inputBackground)
        .cornerRadius(18)
    }
}

private struct SocialCircleButton: View {
    @Environment(\.theme) private var theme
    let label: String
    let backgroundColor: Color
    let textColor: Color
    let gradient: LinearGradient?
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            Group {
                if let gradient {
                    Text(label)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(gradient)
                } else {
                    Text(label)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                }
            }
            .frame(width: 52, height: 52)
            .background(backgroundColor)
            .clipShape(Circle())
            .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(duration: 0.1), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
