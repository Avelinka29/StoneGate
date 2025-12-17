import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Настройки")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
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
                                .foregroundColor(.white.opacity(0.65))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "bell", title: "Уведомления", showChevron: true)
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.leading, 60)
                                SettingsRow(icon: "moon", title: "Темная тема", showChevron: false, showToggle: true)
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.leading, 60)
                                SettingsRow(icon: "globe", title: "Язык", showChevron: true, trailingText: "Русский")
                            }
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("О приложении")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.65))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "info.circle", title: "Версия", showChevron: false, trailingText: "1.0.0")
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.leading, 60)
                                SettingsRow(icon: "doc.text", title: "Лицензия", showChevron: true)
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.leading, 60)
                                SettingsRow(icon: "shield", title: "Политика конфиденциальности", showChevron: true)
                            }
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
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
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
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
    let icon: String
    let title: String
    var showChevron: Bool = false
    var showToggle: Bool = false
    var trailingText: String? = nil
    @State private var isToggleOn = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            if let trailingText = trailingText {
                Text(trailingText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if showToggle {
                Toggle("", isOn: $isToggleOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
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

