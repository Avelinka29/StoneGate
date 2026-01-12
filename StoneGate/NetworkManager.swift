import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    let baseURL = "http://127.0.0.1:8001" // URL FastAPI сервера
    var authToken: String?

    private init() {}

    // MARK: - Generic Request Method

    func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Добавляем токен авторизации если есть
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("DEBUG NetworkManager: Adding Authorization header: Bearer \(token)")
        } else {
            print("DEBUG NetworkManager: No auth token available")
        }

        // Добавляем тело запроса если есть
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        print("DEBUG NetworkManager: Making request to: \(method) \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        print("DEBUG NetworkManager: Response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG NetworkManager: Response body: \(responseString)")
            }

            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.detail)
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func requestNoResponse(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws {

        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Добавляем токен авторизации если есть
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("DEBUG NetworkManager: Adding Authorization header: Bearer \(token)")
        } else {
            print("DEBUG NetworkManager: No auth token available")
        }

        // Добавляем тело запроса если есть
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        print("DEBUG NetworkManager: Making request to: \(method) \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        print("DEBUG NetworkManager: Response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG NetworkManager: Response body: \(responseString)")
            }

            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.detail)
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - Specific API Methods

    func getPortfolio() async throws -> Portfolio {
        return try await request(endpoint: "/portfolio", method: "GET")
    }

    func getUserProfile() async throws -> UserProfile {
        return try await request(endpoint: "/user/profile", method: "GET")
    }

    func updateUserSettings(_ settings: UserSettingsUpdate) async throws -> UserProfile {
        return try await request(endpoint: "/user/settings", method: "PATCH", body: settings)
    }
    
    func updateUserProfile(_ profile: UserProfileUpdate) async throws -> UserProfile {
        return try await request(endpoint: "/user/profile", method: "PATCH", body: profile)
    }
    
    func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse {
        guard let url = URL(string: baseURL + "/user/avatar") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Добавляем токен авторизации
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Создаем multipart/form-data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Добавляем файл
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.detail)
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(AvatarUploadResponse.self, from: data)
    }
    
    func deleteAvatar() async throws {
        guard let url = URL(string: baseURL + "/user/avatar") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.detail)
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }

    func requestVerification() async throws -> VerificationResponse {
        return try await request(endpoint: "/user/verify", method: "POST")
    }

    // MARK: - Error Types

    enum NetworkError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(Int)
        case serverError(String)
        case decodingError

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Неверный URL"
            case .invalidResponse:
                return "Неверный ответ сервера"
            case .httpError(let code):
                return "Ошибка HTTP: \(code)"
            case .serverError(let message):
                return message
            case .decodingError:
                return "Ошибка декодирования данных"
            }
        }
    }

    // MARK: - Error Response Model

    private struct ErrorResponse: Codable {
        let detail: String
    }
}

// MARK: - Extensions for better error handling

extension NetworkManager.NetworkError {
    init(from error: Error) {
        if let networkError = error as? NetworkManager.NetworkError {
            self = networkError
        } else {
            self = .serverError(error.localizedDescription)
        }
    }
}
