import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case unknownError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return NSLocalizedString("INVALID_URL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("INVALID_RESPONSE", comment: "")
        case .noData:
            return NSLocalizedString("NO_DATA", comment: "")
        case .decodingError:
            return NSLocalizedString("DECODING_ERROR", comment: "")
        case .clientError(let statusCode):
            return String(format: NSLocalizedString("CLIENT_ERROR", comment: ""), statusCode)
        case .serverError(let statusCode):
            return String(format: NSLocalizedString("SERVER_ERROR", comment: ""), statusCode)
        case .unknownError(let error):
            return String(format: NSLocalizedString("UNKNOWN_ERROR", comment: ""), error.localizedDescription)
        }
    }
}
