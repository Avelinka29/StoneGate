import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var avatarURL: String?
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var avatarData: Data?
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showDeleteAvatarConfirmation = false
    
    let profile: UserProfile
    let onProfileUpdated: () -> Void
    
    init(profile: UserProfile, onProfileUpdated: @escaping () -> Void) {
        self.profile = profile
        self.onProfileUpdated = onProfileUpdated
        _name = State(initialValue: profile.name)
        _email = State(initialValue: profile.email)
        _phone = State(initialValue: profile.phone ?? "")
        _avatarURL = State(initialValue: profile.avatar_url)
    }
    
    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 52)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        avatarSection
                        formSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Произошла ошибка")
        }
        .confirmationDialog("Удалить аватар?", isPresented: $showDeleteAvatarConfirmation) {
            Button("Удалить", role: .destructive) {
                Task {
                    await deleteAvatar()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    avatarData = data
                    if let uiImage = UIImage(data: data) {
                        avatarImage = Image(uiImage: uiImage)
                    }
                    await uploadAvatar(data)
                }
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
            
            Text("Редактировать профиль")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            Button(action: {
                Task {
                    await saveProfile()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
                } else {
                    Text("Готово")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.accentColor)
                }
            }
            .disabled(isLoading)
        }
        .frame(height: 44)
    }
    
    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                // Аватар
                Group {
                    if let avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                    } else if let avatarURL, let url = URL(string: NetworkManager.shared.baseURL + avatarURL) {
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
                
                // Кнопка редактирования
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(theme.primaryBackground, lineWidth: 2)
                        )
                }
            }
            
            if avatarURL != nil {
                Button(action: {
                    showDeleteAvatarConfirmation = true
                }) {
                    Text("Удалить аватар")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            FormField(
                icon: "person",
                placeholder: "Имя",
                text: $name
            )
            
            FormField(
                icon: "envelope",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            FormField(
                icon: "phone",
                placeholder: "Телефон (необязательно)",
                text: $phone,
                keyboardType: .phonePad
            )
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Actions
    
    private func saveProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let update = UserProfileUpdate(
                name: name.isEmpty ? nil : name,
                email: email.isEmpty ? nil : email,
                phone: phone.isEmpty ? nil : phone
            )
            
            _ = try await NetworkManager.shared.updateUserProfile(update)
            
            await MainActor.run {
                onProfileUpdated()
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
    
    private func uploadAvatar(_ data: Data) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await NetworkManager.shared.uploadAvatar(data)
            await MainActor.run {
                avatarURL = response.avatar_url
                isLoading = false
                onProfileUpdated()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
                // Сброс выбранной фотографии при ошибке
                selectedPhoto = nil
                avatarImage = nil
                avatarData = nil
            }
        }
    }
    
    private func deleteAvatar() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await NetworkManager.shared.deleteAvatar()
            await MainActor.run {
                avatarURL = nil
                avatarImage = nil
                avatarData = nil
                isLoading = false
                onProfileUpdated()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
}

// MARK: - Form Field Component

private struct FormField: View {
    @Environment(\.theme) private var theme
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(theme.secondaryText)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(theme.primaryText)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(theme.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    EditProfileView(
        profile: UserProfile(
            id: 1,
            email: "test@example.com",
            name: "Тест Пользователь",
            phone: "+375291234567",
            avatar_url: nil,
            verified: true,
            biometrics_enabled: false,
            notifications_enabled: true
        ),
        onProfileUpdated: {}
    )
    .environmentObject(ThemeManager.shared)
    .environmentObject(AuthManager())
}
