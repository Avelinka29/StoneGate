import Foundation

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phone: String?
}

struct SocialLoginRequest: Codable {
    let provider: String
    let token: String
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

// MARK: - User Models
struct VerificationResponse: Codable {
    let message: String
    let verified: Bool
}

struct UserProfile: Codable, Identifiable, Equatable {
    let id: Int
    let email: String
    let name: String
    let phone: String?
    let verified: Bool
    let biometrics_enabled: Bool
    let notifications_enabled: Bool

    enum CodingKeys: String, CodingKey {
        case id, email, name, phone, verified
        case biometrics_enabled = "biometrics_enabled"
        case notifications_enabled = "notifications_enabled"
    }

    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.name == rhs.name &&
               lhs.phone == rhs.phone &&
               lhs.verified == rhs.verified &&
               lhs.biometrics_enabled == rhs.biometrics_enabled &&
               lhs.notifications_enabled == rhs.notifications_enabled
    }
}

struct UserSettingsUpdate: Codable {
    let biometrics_enabled: Bool?
    let notifications_enabled: Bool?

    init(biometrics_enabled: Bool? = nil, notifications_enabled: Bool? = nil) {
        self.biometrics_enabled = biometrics_enabled
        self.notifications_enabled = notifications_enabled
    }
}

// MARK: - Portfolio Models
struct Holding: Codable, Identifiable {
    let id: Int
    let name: String
    let symbol: String
    let shares: Int
    let value: Double
    let change: Double
    let change_value: Double

    var formattedValue: String {
        String(format: "%.2f BYN", value)
    }

    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))%"
    }

    var changeColor: String {
        change >= 0 ? "#00FF00" : "#FF4444"
    }
}

struct Portfolio: Codable {
    let total_balance: Double
    let daily_change: Double
    let daily_change_value: Double
    let holdings: [Holding]

    var formattedBalance: String {
        String(format: "%.2f BYN", total_balance)
    }

    var formattedDailyChange: String {
        let sign = daily_change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", daily_change))%"
    }

    var dailyChangeColor: String {
        daily_change >= 0 ? "#00FF00" : "#FF4444"
    }
}

// MARK: - Chart Data Model
struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double

    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}
