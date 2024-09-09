//
//  RequestManager.swift
//  HimiClip
//
//  Created by himicoswilson on 9/8/24.
//

import Foundation
import SwiftUI

class RequestManager{
    
    // 通用的网络请求处理函数
    func performRequest(
        url: URL,
        method: String = "GET",  // 默认使用 GET 请求
        body: [String: Any]? = nil,
        successMessage: String? = nil,
        failureMessage: String = "",
        onSuccess: ((Data) -> Void)? = nil,
        onFailure: (() -> Void)? = nil  // 失败时的回调
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            // 错误处理
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    globalToastManager.showToast(message: failureMessage, type: .failure)
                    onFailure?()
                }
                return
            }

            // 判断响应状态码是否为 200~299 范围内
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    globalToastManager.showToast(message: failureMessage, type: .failure)
                    onFailure?()
                }
                return
            }

            DispatchQueue.main.async {
                onSuccess?(data!)
                successMessage.map { globalToastManager.showToast(message: $0, type: .success) }
            }
        }.resume()
    }
}
