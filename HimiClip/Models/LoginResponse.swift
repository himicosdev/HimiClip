import Foundation

struct LoginResponse: Codable {
    let message: String
    let userId: Int
    let token: String
}