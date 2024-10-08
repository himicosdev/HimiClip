import Foundation

enum APIConstants {
    static let baseURL = ConfigurationManager.shared.baseURL
    
    enum Endpoints {
        static let clips = "/api/clips"
        
        static func clip(_ id: Int) -> String {
            return "\(clips)/\(id)"
        }

        static let register = "/api/register"
        static let login = "/api/login"
        static let sendVerificationCode = "/api/sendCode"
        static let verifyCode = "/api/verifyCode"
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum HTTPHeaderField: String {
        case contentType = "Content-Type"
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
}
