import SwiftUI

struct QuickInvestmentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var investmentAmount: Double = 500
    @State private var selectedStrategy: InvestmentStrategy = .balanced

    private var theme: Theme { Theme() }

    enum InvestmentStrategy {
        case balanced, conservative, growing

        var title: String {
            switch self {
            case .balanced: return "Сбалансированный"
            case .conservative: return "Консервативный"
            case .growing: return "Растущий"
            }
        }

        var subtitle: String {
            switch self {
            case .balanced: return "Средний риск"
            case .conservative: return "Низкий риск"
            case .growing: return "Высокий риск"
            }
        }

        var returnText: String {
            switch self {
            case .balanced: return "8-12% доходность"
            case .conservative: return "5-8% доходность"
            case .growing: return "12-18% доходность"
            }
        }

        var icon: String {
            switch self {
            case .balanced: return "shield.fill"
            case .conservative: return "shield"
            case .growing: return "arrow.up"
            }
        }
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
                            Text("Быстрое инвестирование")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(theme.primaryText)
                                .multilineTextAlignment(.center)

                            Text("Выберите сумму и стратегию")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(theme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Investment Amount Section
                        VStack(spacing: 16) {
                            Text("Сумма инвестиций")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 16) {
                                HStack {
                                    Text("\(Int(investmentAmount))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(theme.primaryText)

                                    Text("BYN")
                                        .font(.system(size: 20, weight: .regular, design: .rounded))
                                        .foregroundColor(theme.secondaryText)
                                }

                                Slider(value: $investmentAmount, in: 10...5000, step: 10)
                                    .accentColor(theme.positiveColor)

                                HStack {
                                    Text("10 BYN")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(theme.secondaryText)

                                    Spacer()

                                    Text("5000 BYN")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(theme.secondaryText)
                                }
                            }
                            .padding(20)
                            .background(theme.secondaryBackground)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)

                        // Strategy Selection Section
                        VStack(spacing: 16) {
                            Text("Выберите стратегию")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 12) {
                                StrategyCard(
                                    strategy: .balanced,
                                    isSelected: selectedStrategy == .balanced,
                                    action: { selectedStrategy = .balanced }
                                )

                                StrategyCard(
                                    strategy: .conservative,
                                    isSelected: selectedStrategy == .conservative,
                                    action: { selectedStrategy = .conservative }
                                )

                                StrategyCard(
                                    strategy: .growing,
                                    isSelected: selectedStrategy == .growing,
                                    action: { selectedStrategy = .growing }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Features Row
                        HStack(spacing: 20) {
                            FeatureIcon(icon: "clock", label: "Без комиссии")
                            FeatureIcon(icon: "shield.fill", label: "Надежно")
                            FeatureIcon(icon: "trophy.fill", label: "Ликвидно")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }

                Spacer()

                // Footer (Fixed at bottom)
                VStack(spacing: 12) {
                    Button(action: {
                        // TODO: Navigate to next step
                        print("Continue with amount: \(Int(investmentAmount)) BYN, strategy: \(selectedStrategy.title)")
                    }) {
                        Text("Продолжить")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.accentColor)
                            .cornerRadius(16)
                    }

                    Text("Нажимая «Продолжить», вы соглашаетесь с условиями инвестирования")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct StrategyCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let strategy: QuickInvestmentView.InvestmentStrategy
    let isSelected: Bool
    let action: () -> Void

    private var theme: Theme { Theme() }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? theme.accentColor : theme.secondaryBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: strategy.icon)
                        .foregroundColor(isSelected ? theme.primaryBackground : theme.primaryText)
                        .font(.system(size: 20, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(strategy.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)

                    Text(strategy.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(theme.secondaryText)

                    Text(strategy.returnText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(theme.positiveColor)
                }

                Spacer()
            }
            .padding(16)
            .background(theme.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct FeatureIcon: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let icon: String
    let label: String

    private var theme: Theme { Theme() }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.secondaryBackground)
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .foregroundColor(theme.primaryText)
                    .font(.system(size: 20, weight: .semibold))
            }

            Text(label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    QuickInvestmentView()
        .environmentObject(ThemeManager.shared)
}