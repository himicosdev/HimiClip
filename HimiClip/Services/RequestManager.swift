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
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        guard let url = URL(string: APIConstants.baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(APIConstants.ContentType.json.rawValue, forHTTPHeaderField: APIConstants.HTTPHeaderField.contentType.rawValue)

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.unknownError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                completion(.success(data))
            case 400...499:
                completion(.failure(.clientError(statusCode: httpResponse.statusCode)))
            case 500...599:
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
            default:
                completion(.failure(.unknownError(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil))))
            }
        }
        tasks.append(task)
        task.resume()
    }
}
