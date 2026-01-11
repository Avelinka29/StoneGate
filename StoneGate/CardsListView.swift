import SwiftUI

struct CardsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager

    private var theme: Theme { Theme() }

    @State private var cards: [CardData] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.primaryText)
                            .frame(width: 32, height: 32)
                    }

                    Spacer()

                    Text("Банковские карты")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)

                    Spacer()

                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryText)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 16)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryText))
                        .scaleEffect(1.5)
                        .padding(.top, 50)
                } else if !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Text("Ошибка загрузки")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(theme.primaryText)

                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Button(action: {
                            loadCards()
                        }) {
                            Text("Попробовать снова")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.primaryBackground)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(theme.accentColor)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 50)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Cards List
                            VStack(spacing: 12) {
                                ForEach(cards) { card in
                                    CardRow(card: card)
                                }
                            }
                            .padding(.horizontal, 20)

                            Spacer(minLength: 40)

                            // Add New Card Button
                            NavigationLink(destination: AddCardView()) {
                                Text("Добавить новую карту")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.primaryBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(theme.accentColor)
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 34)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCards()
        }
    }

    private func loadCards() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                let cardsData: [CardData] = try await NetworkManager.shared.request(endpoint: "/cards", method: "GET")

                await MainActor.run {
                    self.cards = cardsData
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct CardData: Identifiable, Codable {
    let id: Int
    let card_number_masked: String
    let expiry_date: String
    let cardholder_name: String
    let cardholder_surname: String
    let card_type: String
    let is_primary: Bool

    var number: String { card_number_masked }
    var name: String { "\(cardholder_name) \(cardholder_surname)" }
    var type: String { card_type == "home" ? "Домашняя" : "Рабочая" }
    var isPrimary: Bool { is_primary }
}

private struct CardRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let card: CardData

    private var theme: Theme { Theme() }

    var body: some View {
        HStack(spacing: 16) {
            // Bank Logo Placeholder
            ZStack {
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 48, height: 48)

                Image(systemName: "creditcard")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(theme.primaryBackground)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(card.number)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.primaryText)

                Text(card.name)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(theme.secondaryText)

                Text(card.type)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(theme.tertiaryText)
            }

            Spacer()

            if card.isPrimary {
                Text("Основная")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accentColor.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(theme.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationView {
        CardsListView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(AuthManager())
    }
}