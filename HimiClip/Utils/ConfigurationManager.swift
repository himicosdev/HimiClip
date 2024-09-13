import Foundation

enum Environment {
    case development
    case production
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    #if DEBUG
    private let environment: Environment = .development
    #else
    private let environment: Environment = .production
    #endif
    
    var baseURL: String {
        switch environment {
        case .development:
            return "http://localhost:8080"
        case .production:
            return "https://api.himiclip.com"  // 替换为您的实际生产环境 URL
        }
    }
    
    var apiTimeout: TimeInterval {
        switch environment {
        case .development:
            return 30
        case .production:
            return 10
        }
    }
}