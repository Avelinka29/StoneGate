import SwiftUI

struct InvestmentConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    let investmentAmount: Double
    let selectedStrategy: QuickInvestmentView.InvestmentStrategy
    @State private var showSuccessView = false

    private var theme: Theme { Theme() }

    private var commission: Double { 0.0 }
    private var totalAmount: Double { investmentAmount + commission }

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
                            Text("Подтверждение инвестиций")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(theme.primaryText)
                                .multilineTextAlignment(.center)

                            Text("Проверьте детали перед подтверждением")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(theme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Combined Strategy and Details Block
                        VStack(spacing: 24) {
                            // Shield Icon
                            ZStack {
                                Circle()
                                    .fill(theme.accentColor)
                                    .frame(width: 80, height: 80)

                                Image(systemName: "shield")
                                    .foregroundColor(theme.primaryBackground)
                                    .font(.system(size: 32, weight: .semibold))
                            }

                            // Strategy Info
                            VStack(spacing: 4) {
                                Text(selectedStrategy.title)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.positiveColor)

                                Text("Инвестиционный фонд")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(theme.secondaryText)
                            }

                            // Investment Details Section
                            VStack(spacing: 16) {
                                Text("Детали инвестиций")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(spacing: 12) {
                                    InvestmentDetailRow(label: "Сумма инвестиций", value: "\(Int(investmentAmount)) BYN")
                                    InvestmentDetailRow(label: "Комиссия", value: "\(Int(commission)) BYN")
                                    InvestmentDetailRow(label: "Итого к списанию", value: "\(Int(totalAmount)) BYN", isTotal: true)
                                }
                                .padding(20)
                                .background(theme.secondaryBackground)
                                .cornerRadius(16)
                            }
                        }
                        .padding(20)
                        .background(theme.secondaryBackground)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // Account Section
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(theme.accentColor)
                                    .frame(width: 56, height: 56)

                                Image(systemName: "banknote.fill")
                                    .foregroundColor(theme.primaryBackground)
                                    .font(.system(size: 24, weight: .semibold))
                            }

                            VStack(spacing: 4) {
                                Text("Брокерский счет")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.primaryText)

                                Text("5 453.71 BYN")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "checkmark")
                                .foregroundColor(theme.accentColor)
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding(20)
                        .background(theme.accentColor.opacity(0.1))
                        .cornerRadius(16)

                        // Info Box
                        Text("После покупки инвестиций появится в вашем портфеле. Вы сможете отслеживать её динамику и продавать в любое время")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(theme.secondaryText)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .padding(20)
                            .background(theme.secondaryBackground)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }

                Spacer()

                // Footer (Fixed at bottom)
                VStack(spacing: 12) {
                    Button(action: {
                        showSuccessView = true
                    }) {
                        Text("Инвестировать \(Int(investmentAmount)) BYN")
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
        .overlay(
            NavigationLink(destination: InvestmentSuccessView(
                investmentAmount: investmentAmount,
                selectedStrategy: selectedStrategy
            ), isActive: $showSuccessView) {
                EmptyView()
            }
        )
    }
}

private struct InvestmentDetailRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let label: String
    let value: String
    var isTotal: Bool = false

    private var theme: Theme { Theme() }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: isTotal ? 16 : 14, weight: isTotal ? .semibold : .regular, design: .rounded))
                .foregroundColor(isTotal ? theme.primaryText : theme.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: isTotal ? 18 : 16, weight: isTotal ? .bold : .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)
        }
    }
}

#Preview {
    InvestmentConfirmationView(
        investmentAmount: 500,
        selectedStrategy: .balanced
    )
    .environmentObject(ThemeManager.shared)
}