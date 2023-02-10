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
        static let baseURl = "https://serpapi.com/search.json?q="
    }
    
    var endpoint: String
    var ijn: Int
    
    private let pathComponents: [String]
    
    private let queryParameters: [URLQueryItem]
    
    /// Constructed url for the api request in string format
    public var urlString: String {
        let searchString = endpoint.replacingOccurrences(of: " ", with: "%20")
        var string = Constants.baseURl
        string += searchString
        string += "&tbm=isch&ijn="
        string += "\(ijn)"
        string += Constants.apiKey
        
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
    init(searchString: String, ijn: Int = 0, pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
       self.endpoint = searchString
        self.ijn = ijn
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
        
        let trimmed = string.replacingOccurrences(of: Constants.baseURl, with: "")
        if trimmed.contains("&") {
            let components = trimmed.split(separator: "&")
            if !components.isEmpty {
                let searchString = String(components[0])
                let ijn = Int(components[2].replacingOccurrences(of: "ijn=", with: ""))
                self.init(searchString: searchString, ijn: ijn!)
                return
            }
        }
        return nil
    }
}

extension GIRequest {
//    static let listAppleRequest = GIRequest(endpoint: .apple)
//    static let listEpisodeRequest = GIRequest(endpoint: .episode)
}
