import SwiftUI

struct InvestmentSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    let investmentAmount: Double
    let selectedStrategy: QuickInvestmentView.InvestmentStrategy
    @State private var showDashboard = false
    @State private var showInvestmentMethod = false

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
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Success Icon
                        ZStack {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 80, height: 80)

                            Image(systemName: "checkmark")
                                .foregroundColor(theme.primaryBackground)
                                .font(.system(size: 32, weight: .bold))
                        }
                        .padding(.vertical, 16)

                        // Success Title
                        VStack(spacing: 8) {
                            Text("Инвестиция успешно создана!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(theme.primaryText)
                                .multilineTextAlignment(.center)

                            Text("Вы инвестировали \(Int(investmentAmount)) BYN в фонд '\(selectedStrategy.title)'")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(theme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Combined Investment Card and Details
                        VStack(spacing: 20) {
                            // Investment Card
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(theme.accentColor)
                                        .frame(width: 48, height: 48)

                                    Image(systemName: selectedStrategy.icon)
                                        .foregroundColor(theme.primaryBackground)
                                        .font(.system(size: 20, weight: .semibold))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedStrategy.title)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(theme.positiveColor)

                                    Text("Инвестиция активирована")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(theme.secondaryText)
                                }

                                Spacer()
                            }

                            // Details
                            VStack(spacing: 12) {
                                InvestmentDetailRow(label: "Сумма", value: "\(Int(investmentAmount)) BYN")
                                InvestmentDetailRow(label: "Статус", value: "Активна", isStatus: true)
                            }
                        }
                        .padding(20)
                        .background(theme.secondaryBackground)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // Info Text
                        Text("Инвестиция добавлена в ваш портфель. Следите за доходностью в разделе 'Главная'")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(theme.secondaryText)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }

                Spacer()

                // Footer (Fixed at bottom)
                VStack(spacing: 12) {
                    Button(action: {
                        showDashboard = true
                    }) {
                        Text("Посмотреть портфель")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.accentColor)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        showInvestmentMethod = true
                    }) {
                        Text("Продолжить инвестировать")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.secondaryBackground)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .navigationBarHidden(true)
        .overlay(
            Group {
                NavigationLink(destination: DashboardView(), isActive: $showDashboard) {
                    EmptyView()
                }
                NavigationLink(destination: InvestmentMethodView(), isActive: $showInvestmentMethod) {
                    EmptyView()
                }
            }
        )
    }
}

private struct InvestmentDetailRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let label: String
    let value: String
    var isStatus: Bool = false

    private var theme: Theme { Theme() }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(theme.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isStatus ? theme.positiveColor : theme.primaryText)
        }
    }
}

#Preview {
    InvestmentSuccessView(
        investmentAmount: 500,
        selectedStrategy: .balanced
    )
    .environmentObject(ThemeManager.shared)
}