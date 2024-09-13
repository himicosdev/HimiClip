import Foundation
import SwiftUI

extension Notification.Name {
    static let userDidAuthenticate = Notification.Name("userDidAuthenticate")
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private let tokenKey = "userToken"
    private let userKey = "currentUser"
    
    init() {
        self.isAuthenticated = UserDefaults.standard.string(forKey: tokenKey) != nil
        if let userData = UserDefaults.standard.data(forKey: userKey),
            let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        }
    }
    
    func login(with response: LoginResponse) {
        UserDefaults.standard.set(response.token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
        self.isAuthenticated = true
        self.currentUser = response.user
        NotificationCenter.default.post(name: .userDidAuthenticate, object: nil)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.isAuthenticated = false
        self.currentUser = nil
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
}

struct User: Codable {
    let id: Int
    let username: String
    let email: String
}