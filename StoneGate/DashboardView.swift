import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showInvestmentModal = false
    @State private var showLearningView = false

    private var theme: Theme {
        ThemeManager.shared.isDarkMode ? Theme() : Theme()
    }
    private let chartPoints: [CGPoint] = [
        CGPoint(x: 0, y: 110),
        CGPoint(x: 40, y: 90),
        CGPoint(x: 80, y: 120),
        CGPoint(x: 120, y: 95),
        CGPoint(x: 160, y: 140),
        CGPoint(x: 200, y: 110),
        CGPoint(x: 240, y: 150),
        CGPoint(x: 280, y: 130),
        CGPoint(x: 320, y: 165)
    ]

    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 20) {
                            topNavigation
                            balanceBlock
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        
                        chartBlock
                            .padding(.horizontal, 0)
                        
                        VStack(spacing: 20) {
                            tabsBlock
                            holdingsList
                            PartialHoldingRow()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                investButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [theme.primaryBackground.opacity(0), theme.primaryBackground]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    )
            }
        }
        .overlay(
            Group {
                if showInvestmentModal {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showInvestmentModal = false
                        }

                    InvestmentModalView(isPresented: $showInvestmentModal) {
                        showLearningView = true
                    }
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .background(
                NavigationLink(destination: LearningView(), isActive: $showLearningView) {
                    EmptyView()
                }
            )
        )
    }

    private var topNavigation: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: ProfileView()) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=200&q=80")) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else {
                        theme.secondaryBackground
                    }
                }
                .frame(width: 34, height: 34)
                .clipShape(Circle())
            }

            Spacer()

            Text("Главная")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)

            Spacer()

            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .foregroundColor(theme.primaryText)
                    .font(.title3)
            }
        }
    }

    private var balanceBlock: some View {
        VStack(spacing: 6) {
            Text("Общий баланс")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(theme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("5 453,71 BYN")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("За сегодня +132,60 BYN (+4,23%)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.positiveColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var chartBlock: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height: CGFloat = 180
            let normalizedPoints = normalizePoints(chartPoints, width: width, height: height)
            
            ZStack {
                // Fill area
                Path { path in
                    guard let first = normalizedPoints.first else { return }
                    path.move(to: first)
                    
                    for i in 0..<normalizedPoints.count - 1 {
                        let current = normalizedPoints[i]
                        let next = normalizedPoints[i + 1]
                        let controlPoint1 = CGPoint(x: current.x + (next.x - current.x) * 0.5, y: current.y)
                        let controlPoint2 = CGPoint(x: current.x + (next.x - current.x) * 0.5, y: next.y)
                        path.addCurve(to: next, control1: controlPoint1, control2: controlPoint2)
                    }
                    
                    if let last = normalizedPoints.last {
                        path.addLine(to: CGPoint(x: last.x, y: height))
                        path.addLine(to: CGPoint(x: first.x, y: height))
                    }
                    path.closeSubpath()
                }
                .fill(theme.chartFillGradient)
                
                // Line stroke
                Path { path in
                    guard let first = normalizedPoints.first else { return }
                    path.move(to: first)
                    
                    for i in 0..<normalizedPoints.count - 1 {
                        let current = normalizedPoints[i]
                        let next = normalizedPoints[i + 1]
                        let controlPoint1 = CGPoint(x: current.x + (next.x - current.x) * 0.5, y: current.y)
                        let controlPoint2 = CGPoint(x: current.x + (next.x - current.x) * 0.5, y: next.y)
                        path.addCurve(to: next, control1: controlPoint1, control2: controlPoint2)
                    }
                }
                .stroke(theme.chartLineColor, lineWidth: 3)
            }
        }
        .frame(height: 180)
        .padding(.vertical, 8)
    }
    
    private func normalizePoints(_ points: [CGPoint], width: CGFloat, height: CGFloat) -> [CGPoint] {
        guard let minX = points.map(\.x).min(),
              let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(),
              let maxY = points.map(\.y).max(),
              maxX > minX, maxY > minY else {
            return points
        }
        
        return points.map { point in
            CGPoint(
                x: (point.x - minX) / (maxX - minX) * width,
                y: height - (point.y - minY) / (maxY - minY) * (height - 40) - 20
            )
        }
    }

    private var tabsBlock: some View {
        let labels = ["1Д", "1Н", "1М", "6М", "1Г", "Все"]
        return HStack(spacing: 10) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.primaryText)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(theme.secondaryBackground)
                    .cornerRadius(14)
            }
        }
    }

    private var holdingsList: some View {
        VStack(spacing: 12) {
            HoldingRow(logoColor: Color.white, iconText: "СБЕР", title: "Сбер Банк", subtitle: "58 акций", amount: "1852,38 BYN", change: "+232,60 BYN (+5,81%)")
            HoldingRow(logoColor: Color(red: 0.0, green: 0.7, blue: 0.25), iconText: "АПБ", title: "Белагропромбанк", subtitle: "321 акция", amount: "723,84 BYN", change: "+82,12 BYN (+12,87%)")
            HoldingRow(logoColor: Color(red: 0.8, green: 0.0, blue: 0.0), iconText: "A", title: "Alfa Bank", subtitle: "22 акции", amount: "521,58 BYN", change: "+9,60 BYN (+1,39%)")
            HoldingRow(logoColor: Color(red: 0.22, green: 0.55, blue: 0.13), iconText: "e", title: "Европт", subtitle: "8 акций", amount: "149,91 BYN", change: "+2,62 BYN (+0,9%)")
        }
    }

    private var investButton: some View {
        Button(action: {
            showInvestmentModal = true
        }) {
            Text("Инвестировать")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(theme.primaryBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.accentColor)
                .cornerRadius(26)
        }
    }
}

private struct HoldingRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let logoColor: Color
    let iconText: String
    let title: String
    let subtitle: String
    let amount: String
    let change: String

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(logoColor)
                .frame(width: 56, height: 56)
                .overlay(
                    Text(iconText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(logoColor == .white ? theme.primaryText : theme.primaryBackground)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.primaryText)
                Text(change)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(theme.positiveColor)
            }
        }
        .padding()
        .background(theme.tertiaryBackground)
        .cornerRadius(16)
    }
}

private struct PartialHoldingRow: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.08, green: 0.14, blue: 0.35))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "flag.fill")
                        .foregroundColor(theme.primaryBackground)
                        .font(.title3)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Доп. сделки")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.primaryText)
                Text("38 акций")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("...")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.primaryText)
                Text("+7,74 BYN (+4,51%)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(theme.positiveColor)
            }
        }
        .padding()
        .background(theme.tertiaryBackground)
        .cornerRadius(16)
    }
}

private struct InvestmentModalView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    var onStartLearning: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Text("Научём инвестировать?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primaryText)

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                        .frame(width: 28, height: 28)
                        .background(theme.tertiaryBackground)
                        .clipShape(Circle())
                }
            }

            // Subtitle
            Text("Выберите, как вы хотите начать")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)

            // Buttons
            VStack(spacing: 12) {
                // Пройти обучение button
                Button(action: {
                    isPresented = false
                    onStartLearning?()
                }) {
                        HStack(spacing: 12) {
                            Image(systemName: "book.open")
                                .font(.system(size: 18))
                                .foregroundColor(theme.primaryBackground)

                            Text("Пройти обучение")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.primaryBackground)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.accentColor)
                    .cornerRadius(12)
                }

                // Начать сразу button
                Button(action: {
                    // TODO: Navigate to main investment interface
                    print("Starting investment interface...")
                    isPresented = false
                }) {
                        HStack(spacing: 12) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 18))
                                .foregroundColor(theme.primaryText)

                            Text("Начать сразу")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.secondaryBackground)
                    .cornerRadius(12)
                }
            }

            // Footer text
            Text("Если вы новичок, мы рекомендуем пройти обучение. Оно займёт немного времени.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(theme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(20)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 10)
        .frame(width: 320)
    }
}

#Preview {
    DashboardView()
}
