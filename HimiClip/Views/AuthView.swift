import SwiftUI

struct AuthView: View {
    @State private var isLogin = true
    @State private var usernameOrEmail = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var verificationCode = ""
    
    private let requestManager = RequestManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Picker("Mode", selection: $isLogin) {
                        Text(NSLocalizedString("LOGIN", comment: "")).tag(true)
                        Text(NSLocalizedString("REGISTER", comment: "")).tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if isLogin {
                        TextField(NSLocalizedString("USERNAME_OR_EMAIL", comment: ""), text: $usernameOrEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                    } else {
                        TextField(NSLocalizedString("EMAIL", comment: ""), text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                        
                        HStack {
                            TextField(NSLocalizedString("VERIFICATION_CODE", comment: ""), text: $verificationCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            Button(action: sendVerificationCode) {
                                Text(NSLocalizedString("SEND_CODE", comment: ""))
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        
                        TextField(NSLocalizedString("USERNAME", comment: ""), text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    
                    SecureField(NSLocalizedString("PASSWORD", comment: ""), text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if isLogin {
                            login()
                        } else {
                            register()
                        }
                    }) {
                        Text(isLogin ? NSLocalizedString("LOGIN", comment: "") : NSLocalizedString("REGISTER", comment: ""))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationBarTitle(NSLocalizedString("HIMICLIP", comment: ""))
            .overlay(
                ToastView()
                    .padding(.bottom, 50)
                , alignment: .bottom
            )
        }
    }
    
    func login() {
        guard !usernameOrEmail.isEmpty, !password.isEmpty else {
            globalToastManager.showToast(message: NSLocalizedString("EMPTY_FIELDS", comment: ""), type: .warning)
            return
        }
        
        let body: [String: Any] = ["usernameOrEmail": usernameOrEmail, "password": password]
        
        requestManager.performRequest(endpoint: APIConstants.Endpoints.login, method: .post, body: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        UserDefaults.standard.set(loginResponse.token, forKey: "userToken")
                        UserDefaults.standard.set(loginResponse.userId, forKey: "userId")
                        NotificationCenter.default.post(name: .userDidAuthenticate, object: nil)
                        globalToastManager.showToast(message: NSLocalizedString("LOGIN_SUCCESS", comment: ""), type: .success)
                    } else {
                        globalToastManager.showToast(message: NSLocalizedString("INVALID_RESPONSE", comment: ""), type: .failure)
                    }
                case .failure(let error):
                    globalToastManager.showToast(message: error.localizedDescription, type: .failure)
                }
            }
        }
    }
    
    func register() {
        guard !email.isEmpty, !verificationCode.isEmpty, !username.isEmpty, !password.isEmpty else {
            globalToastManager.showToast(message: NSLocalizedString("EMPTY_FIELDS", comment: ""), type: .warning)
            return
        }
        
        // 首先验证验证码
        let verifyCodeBody: [String: Any] = [
            "email": email,
            "code": verificationCode
        ]
        
        requestManager.performRequest(endpoint: APIConstants.Endpoints.verifyCode, method: .post, body: verifyCodeBody) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    // 验证码正确，继续注册流程
                    self.performRegistration()
                case .failure(_):
                    globalToastManager.showToast(message: NSLocalizedString("VERIFICATION_CODE_ERROR", comment: ""), type: .failure)
                }
            }
        }
    }
    
    private func performRegistration() {
        let registerBody: [String: Any] = [
            "username": username,
            "password": password,
            "email": email
        ]
        
        requestManager.performRequest(endpoint: APIConstants.Endpoints.register, method: .post, body: registerBody) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    globalToastManager.showToast(message: NSLocalizedString("REGISTER_SUCCESS", comment: ""), type: .success)
                    self.isLogin = true // 切换到登录界面
                case .failure(let error):
                    globalToastManager.showToast(message: error.localizedDescription, type: .failure)
                }
            }
        }
    }
    
    func sendVerificationCode() {
        guard !email.isEmpty else {
            globalToastManager.showToast(message: NSLocalizedString("EMPTY_EMAIL", comment: ""), type: .warning)
            return
        }
        
        let body: [String: Any] = ["email": email]
        
        requestManager.performRequest(endpoint: APIConstants.Endpoints.sendVerificationCode, method: .post, body: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if String(data: data, encoding: .utf8) != nil {
                        globalToastManager.showToast(message: NSLocalizedString("VERIFICATION_CODE_SENT", comment: ""), type: .success)
                    } else {
                        globalToastManager.showToast(message: NSLocalizedString("INVALID_RESPONSE", comment: ""), type: .failure)
                    }
                case .failure(let error):
                    globalToastManager.showToast(message: error.localizedDescription, type: .failure)
                }
            }
        }
    }
}

// MARK: - Previews
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
