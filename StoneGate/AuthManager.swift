import SwiftUI
import Combine
import LocalAuthentication
import Security

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let keychainService = "com.stonegate.auth"
    private let tokenKey = "authToken"

    init() {
        // Проверяем сохраненный токен при запуске
        Task { @MainActor in
            await checkExistingAuth()
        }
    }

    // MARK: - Authentication Methods

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let loginData = LoginRequest(email: email, password: password)
            let response: TokenResponse = try await NetworkManager.shared.request(
                endpoint: "/auth/login",
                method: "POST",
                body: loginData
            )

            // Сохраняем токен
            saveToken(response.access_token)

            // Получаем профиль пользователя
            try await fetchUserProfile()

            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register(name: String, email: String, password: String, phone: String? = nil) async {
        isLoading = true
        errorMessage = ""

        do {
            let registerData = RegisterRequest(name: name, email: email, password: password, phone: phone)
            let response: TokenResponse = try await NetworkManager.shared.request(
                endpoint: "/auth/register",
                method: "POST",
                body: registerData
            )

            // Сохраняем токен
            saveToken(response.access_token)

            // Получаем профиль пользователя
            try await fetchUserProfile()

            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func socialLogin(provider: String) async {
        isLoading = true
        errorMessage = ""

        do {
            // Для прототипа используем mock токен
            let mockToken = UUID().uuidString
            let socialData = SocialLoginRequest(provider: provider, token: mockToken)

            let response: TokenResponse = try await NetworkManager.shared.request(
                endpoint: "/auth/social-login",
                method: "POST",
                body: socialData
            )

            saveToken(response.access_token)
            try await fetchUserProfile()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        clearToken()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Biometric Authentication

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Войти с помощью биометрии"
            )
            return success
        } catch {
            return false
        }
    }

    // MARK: - User Profile

    func fetchUserProfile() async throws {
        let profile: UserProfile = try await NetworkManager.shared.request(
            endpoint: "/user/profile",
            method: "GET"
        )
        currentUser = profile
    }

    func updateSettings(biometricsEnabled: Bool? = nil, notificationsEnabled: Bool? = nil) async {
        do {
            let updateData = UserSettingsUpdate(
                biometrics_enabled: biometricsEnabled,
                notifications_enabled: notificationsEnabled
            )

            let updatedProfile: UserProfile = try await NetworkManager.shared.request(
                endpoint: "/user/settings",
                method: "PATCH",
                body: updateData
            )

            currentUser = updatedProfile
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Token Management

    private func saveToken(_ token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)

        // Устанавливаем токен в NetworkManager для использования в запросах
        NetworkManager.shared.authToken = token
    }

    private func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    private func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)

        // Очищаем токен из NetworkManager
        NetworkManager.shared.authToken = nil
    }

    private func checkExistingAuth() async {
        if let token = getToken() {
            NetworkManager.shared.authToken = token
            // В реальном приложении здесь проверили бы валидность токена
            isAuthenticated = true
            do {
                try await fetchUserProfile()
            } catch {
                // Если не удалось получить профиль, сбрасываем авторизацию
                clearToken()
                isAuthenticated = false
            }
        }
    }
}
