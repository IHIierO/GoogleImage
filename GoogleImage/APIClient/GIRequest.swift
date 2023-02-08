//
//  GIRequest.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

/// Objects that represents a singlet API call
final class GIRequest {
    
    // MARK: - Constants
    private struct Constants {
        static let baseURl = "https://serpapi.com/search.json?q"
    }
    
    let endpoint: GIEndpoint
    
    private let pathComponents: [String]
    
    private let queryParameters: [URLQueryItem]
    
    /// Constructed url for the api request in string format
    public var urlString: String {
        //https://serpapi.com/search.json?q=Apple&tbm=isch&ijn=0
        var string = Constants.baseURl
        string += "="
        string += endpoint.rawValue
        string += "&tbm=isch&ijn=0"
        //string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }

        if !queryParameters.isEmpty {
            string += "?"
            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else {return nil}
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            string += argumentString
        }
        
        return string
    }
    
    /// Computed  & Construct API url
    public var url: URL? {
        return URL(string: urlString)
    }
    
    /// Desired http method
    public let httpMethod = "GET"
    
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of path components
    ///   - queryParameters: Collection of query parameters
    init(endpoint: GIEndpoint, pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    /// Attempt to create request
    /// - Parameter url: URl to parse
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseURl) {
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constants.baseURl+"=", with: "")
        if trimmed.contains("=") {
            let components = trimmed.components(separatedBy: "=")
            if !components.isEmpty {
                let endpointString = components[0]
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let giEndpoint = GIEndpoint(rawValue: endpointString) {
                    self.init(endpoint: giEndpoint, pathComponents: pathComponents)
                    return
                }
            }
        }
//           else if trimmed.contains("?") {
//            let components = trimmed.components(separatedBy: "?")
//            if !components.isEmpty, components.count >= 2 {
//                let endpointString = components[0]
//                let queryItemsString = components[1]
//                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
//                    guard $0.contains("=") else {
//                        return nil
//                    }
//
//                    let parts = $0.components(separatedBy: "=")
//                    return URLQueryItem(
//                        name: parts[0],
//                        value: parts[1])
//                })
//                if let giEndpoint = GIEndpoint(rawValue: endpointString) {
//                    self.init(endpoint: giEndpoint, queryParameters: queryItems)
//                    return
//                }
//            }
//        }
        return nil
    }
}

extension GIRequest {
    static let listAppleRequest = GIRequest(endpoint: .apple)
    static let listEpisodeRequest = GIRequest(endpoint: .episode)
}
