//
//  GIService.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

/// Primary API service object to get Google image data
final class GIService {
    
    /// Shared singleton instance
    static let shared = GIService()
    
    private let cacheManager = GIAPICacheManager()
    
    /// Privatized constructor
    private init() {}
    
    enum GIServiceError: Error {
        case filedToCreateRequest
        case filedToGetData
    }
    
    /// Send Google Image API call
    /// - Parameters:
    ///   - request: Request instatce
    ///   - type: The type of object we expect to get back
    ///   - completion: Callback with data or error
    public func execute<T: Codable>(
        _ request: GIRequest,
        expexting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let cacheData = cacheManager.cacheResponse(for: request.endpoint, url: request.url) {
            do {
                let result = try JSONDecoder().decode(type.self, from: cacheData)
                completion(.success(result))
            }
            
            catch {
                completion(.failure(error))
            }
            return
        }
        
        guard let urlRequest = self.request(from: request) else {
            completion(.failure(GIServiceError.filedToCreateRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? GIServiceError.filedToGetData))
                return
            }
            
            // Decode response
            do {
                print("DATA: - \(data)")
                let result = try JSONDecoder().decode(type.self, from: data)
                self?.cacheManager.setCache(for: request.endpoint, url: request.url, data: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func request(from giRequest: GIRequest) -> URLRequest? {
        print("URL to Request: - \(giRequest.url)")
        guard let url = giRequest.url else {return nil}
        var request = URLRequest(url: url)
        request.httpMethod = giRequest.httpMethod
        return request
    }
    
}
