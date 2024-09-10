import Foundation

enum APIConstants {
    static let baseURL = "http://localhost:8080"
    
    enum Endpoints {
        static let clips = "/api/clips"
        
        static func clip(_ id: Int) -> String {
            return "\(clips)/\(id)"
        }
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
