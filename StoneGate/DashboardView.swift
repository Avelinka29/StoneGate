import SwiftUI

struct DashboardView: View {
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
            Color.black.ignoresSafeArea()

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
                            gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    )
            }
        }
    }

    private var topNavigation: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: ProfileView()) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=200&q=80")) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 34, height: 34)
                .clipShape(Circle())
            }

            Spacer()

            Text("Главная")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .foregroundColor(.white)
                    .font(.title3)
            }
        }
    }

    private var balanceBlock: some View {
        VStack(spacing: 6) {
            Text("Общий баланс")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("5 453,71 BYN")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("За сегодня +132,60 BYN (+4,23%)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.green)
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
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.45), Color.green.opacity(0.02)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
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
                .stroke(Color.green, lineWidth: 3)
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
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.18))
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
        Button(action: {}) {
            Text("Инвестировать")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .cornerRadius(26)
        }
    }
}

private struct HoldingRow: View {
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
                        .foregroundColor(logoColor == .white ? .black : .white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(change)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        .cornerRadius(16)
    }
}

private struct PartialHoldingRow: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.08, green: 0.14, blue: 0.35))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "flag.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Доп. сделки")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("38 акций")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("...")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("+7,74 BYN (+4,51%)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        .cornerRadius(16)
    }
}

#Preview {
    DashboardView()
}
