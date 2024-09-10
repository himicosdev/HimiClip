//
//  RequestManager.swift
//  HimiClip
//
//  Created by himicoswilson on 9/8/24.
//

import Foundation
import SwiftUI

class RequestManager {
    private var tasks: [URLSessionDataTask] = []
    
    func cancelAllTasks() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    // 通用的网络请求处理函数
    func performRequest(
        endpoint: String,
        method: APIConstants.HTTPMethod = .get,
        body: [String: Any]? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: APIConstants.baseURL + endpoint) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(APIConstants.ContentType.json.rawValue, forHTTPHeaderField: APIConstants.HTTPHeaderField.contentType.rawValue)
        
        // 添加token到请求头
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
