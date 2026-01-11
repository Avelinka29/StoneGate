import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardholderName = ""
    @State private var cardholderSurname = ""
    @State private var cardType: CardType = .home
    @State private var isLoading = false
    @State private var errorMessage = ""

    private var theme: Theme { Theme() }

    enum CardType: String {
        case home = "Домашняя"
        case work = "Рабочая"
    }

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

                    Text("Добавить банковскую карту")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Card Form Fields
                        VStack(spacing: 16) {
                            CardTextField(
                                title: "Номер карты",
                                placeholder: "**** **** **** ****",
                                text: $cardNumber,
                                keyboardType: .numberPad
                            )

                            HStack(spacing: 16) {
                                CardTextField(
                                    title: "Дата истечения",
                                    placeholder: "MM/ГГ",
                                    text: $expiryDate,
                                    keyboardType: .numberPad
                                )

                                CardTextField(
                                    title: "CVV/CVC",
                                    placeholder: "***",
                                    text: $cvv,
                                    keyboardType: .numberPad,
                                    isSecure: true
                                )
                            }

                            CardTextField(
                                title: "Имя владельца",
                                placeholder: "Введите имя",
                                text: $cardholderName,
                                keyboardType: .namePhonePad
                            )

                            CardTextField(
                                title: "Фамилия владельца",
                                placeholder: "Введите фамилию",
                                text: $cardholderSurname,
                                keyboardType: .namePhonePad
                            )
                        }
                        .padding(.horizontal, 20)

                        // Card Type Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Сохранить как")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(theme.primaryText)
                                .padding(.horizontal, 20)

                            HStack(spacing: 12) {
                                CardTypeButton(
                                    title: "Домашняя",
                                    isSelected: cardType == .home
                                ) {
                                    cardType = .home
                                }

                                CardTypeButton(
                                    title: "Рабочая",
                                    isSelected: cardType == .work
                                ) {
                                    cardType = .work
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)

                        // Error message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(theme.negativeColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        // Add Card Button
                        Button(action: {
                            addCard()
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryBackground))
                                    .scaleEffect(1.2)
                            } else {
                                Text("Добавить карту")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.primaryBackground)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accentColor)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                        .disabled(!isFormValid || isLoading)
                        .opacity((isFormValid && !isLoading) ? 1.0 : 0.5)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var isFormValid: Bool {
        !cardNumber.isEmpty &&
        !expiryDate.isEmpty &&
        !cvv.isEmpty &&
        !cardholderName.isEmpty &&
        !cardholderSurname.isEmpty
    }

    private func addCard() {
        isLoading = true
        errorMessage = ""

        let cardData = [
            "card_number": cardNumber,
            "expiry_date": expiryDate,
            "cardholder_name": cardholderName,
            "cardholder_surname": cardholderSurname,
            "card_type": cardType.rawValue,
            "is_primary": false
        ] as [String: Any]

        // Create a proper Encodable struct for the request
        struct CardCreateRequest: Encodable {
            let card_number: String
            let expiry_date: String
            let cardholder_name: String
            let cardholder_surname: String
            let card_type: String
            let is_primary: Bool
        }

        let requestData = CardCreateRequest(
            card_number: cardNumber,
            expiry_date: expiryDate,
            cardholder_name: cardholderName,
            cardholder_surname: cardholderSurname,
            card_type: cardType.rawValue,
            is_primary: false
        )

        Task {
            do {
                let _: CardData = try await NetworkManager.shared.request(endpoint: "/cards", method: "POST", body: requestData)
                await MainActor.run {
                    isLoading = false
                    dismiss()
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

private struct CardTextField: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    private var theme: Theme { Theme() }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.secondaryText)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .autocapitalization(.words)
            .disableAutocorrection(true)
            .font(.system(size: 16))
            .foregroundColor(theme.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(theme.inputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.borderColor, lineWidth: 1)
            )
        }
    }
}

private struct CardTypeButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private var theme: Theme { Theme() }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? theme.primaryBackground : theme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(isSelected ? theme.accentColor : theme.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : theme.borderColor, lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationView {
        AddCardView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(AuthManager())
    }
}