import Foundation

struct LoginResponse: Codable {
    let message: String
    let user: User
    let token: String
}