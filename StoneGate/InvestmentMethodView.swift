import SwiftUI

struct InvestmentMethodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    private var theme: Theme { Theme() }

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

                    Text("Выберите способ инвестирования")
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
                        // Header
                        VStack(spacing: 8) {
                            Text("Мы поможем начать Ваш путь к финансовой независимости")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(theme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Investment methods cards
                        VStack(spacing: 12) {
                            InvestmentMethodCard(
                                icon: "arrow.up",
                                title: "Быстрое инвестирование",
                                subtitle: "С минимальной суммой",
                                action: {
                                    // TODO: Navigate to quick investment
                                }
                            )

                            InvestmentMethodCard(
                                icon: "wallet.pass",
                                title: "Создать портфель",
                                subtitle: "Диверсифицированный портфель суммой",
                                action: {
                                    // TODO: Navigate to portfolio creation
                                }
                            )

                            InvestmentMethodCard(
                                icon: "target",
                                title: "Инвестировать на цель",
                                subtitle: "Накопите на важную покупку",
                                action: {
                                    // TODO: Navigate to goal investment
                                }
                            )

                            InvestmentMethodCard(
                                icon: "book.open",
                                title: "Обучение",
                                subtitle: "Узнайте основы инвестирования",
                                action: {
                                    // TODO: Navigate to learning
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()

                // Footer (Fixed at bottom)
                VStack(spacing: 16) {
                    Text("Доступно для инвестирования")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(theme.secondaryText)

                    Text("5 453.71 BYN")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(theme.positiveColor)

                    Button(action: {
                        // TODO: Navigate to deposit
                    }) {
                        Text("Пополнить")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.accentColor)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct InvestmentMethodCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    private var theme: Theme { Theme() }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .foregroundColor(theme.primaryBackground)
                        .font(.system(size: 20, weight: .semibold))
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(theme.secondaryText)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.secondaryText)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(20)
            .background(theme.secondaryBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    InvestmentMethodView()
        .environmentObject(ThemeManager.shared)
}