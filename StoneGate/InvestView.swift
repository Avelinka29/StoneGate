import SwiftUI

struct InvestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var showInvestmentMethodView = false

    private var theme: Theme { Theme() }

    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation Bar
                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.primaryText)
                            .frame(width: 32, height: 32)
                    }

                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.secondaryText)
                            .font(.system(size: 16))

                        TextField("Бумага или компания", text: $searchText)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(theme.primaryText)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Бумага или компания")
                                    .foregroundColor(theme.placeholderText)
                                    .font(.system(size: 16, design: .rounded))
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(theme.inputBackground)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Green "Start Investing" Button
                        Button(action: {
                            showInvestmentMethodView = true
                        }) {
                            Text("Начать инвестировать")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(theme.primaryBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accentColor)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)

                        // Grid of 4 cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                // Top-left: Deposit card
                                InvestCard(
                                    icon: Image(systemName: "plus"),
                                    title: "Пополнить",
                                    iconColor: .white,
                                    circleColor: theme.secondaryBackground
                                )
                                .frame(maxWidth: .infinity)

                                // Top-right: Favorites card
                                InvestCard(
                                    icon: Image(systemName: "star"),
                                    title: "Избранное",
                                    iconColor: theme.primaryText,
                                    circleColor: theme.secondaryBackground
                                )
                                .frame(maxWidth: .infinity)
                            }

                            HStack(spacing: 16) {
                                // Bottom-left: Tell where to start card
                                InvestCard(
                                    title: "Рассказать,\nс чего начать",
                                    iconColor: .white,
                                    circleColor: theme.secondaryBackground,
                                    isTextOnly: true
                                )
                                .frame(maxWidth: .infinity)

                                // Bottom-right: Auction stocks card
                                InvestCard(
                                    title: "Акции с аукциона\nот убойка",
                                    iconColor: .white,
                                    circleColor: theme.secondaryBackground,
                                    isTextOnly: true
                                )
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Combined balance and currency section
                        VStack(spacing: 20) {
                            // Balance section
                            VStack(spacing: 8) {
                                HStack {
                                    Text("100 BYN")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(theme.primaryText)

                                    Spacer()

                                    Text("0 BYN (0%)")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(theme.positiveColor)
                                }

                                Text("Брокерский счет")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(theme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Bottom card: Belarusian ruble
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(theme.secondaryBackground)
                                        .frame(width: 48, height: 48)

                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                }

                                Text("Белорусский рубль")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.primaryText)

                                Spacer()

                                Text("100 BYN")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        .padding(20)
                        .background(theme.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(
            NavigationLink(destination: InvestmentMethodView(), isActive: $showInvestmentMethodView) {
                EmptyView()
            }
        )
    }
}

private struct InvestCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let icon: Image?
    let title: String
    var iconColor: Color = .white
    var circleColor: Color = Color.gray
    var isTextOnly: Bool = false

    init(icon: Image? = nil, title: String, iconColor: Color = .white, circleColor: Color = Color.gray, isTextOnly: Bool = false) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.circleColor = circleColor
        self.isTextOnly = isTextOnly
    }

    private var theme: Theme { Theme() }

    var body: some View {
        VStack(spacing: 12) {
            if !isTextOnly {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 48, height: 48)

                    if let icon = icon {
                        icon
                            .foregroundColor(iconColor)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
            }

            Text(title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(theme.secondaryBackground)
        .cornerRadius(16)
    }
}

// Extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    InvestView()
        .environmentObject(ThemeManager.shared)
}