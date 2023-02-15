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
        static let apiKey = "&api_key=f50b8ba8b7f5427d4a8fe0e41ec7a1b42547705e379884fba9e1e3d72d4ab7d0"
    }
    
    var searchString: String
    var ijn: Int
    
    private let pathComponents: [String]
    
    private let queryParameters: [URLQueryItem]
    
    /// Constructed url for the api request in string format
    public var urlString: String {
        //let searchString = searchString.replacingOccurrences(of: " ", with: "%20")
        var string = Constants.baseURl
        string += searchString
        string += "&tbm=isch&ijn="
        string += "\(ijn)"
        string += Constants.apiKey
        
        return string
    }
    
    /// Computed  & Construct API url
    public var url: URL? {
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encodedUrlString)
    }
    
    /// Desired http method
    public let httpMethod = "GET"
    
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of path components
    ///   - queryParameters: Collection of query parameters
    init(searchString: String, ijn: Int = 0, pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
       self.searchString = searchString
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
                guard let ijn = Int(components[2].replacingOccurrences(of: "ijn=", with: "")) else {
                    return nil
                }
                self.init(searchString: searchString, ijn: ijn)
                return
            }
        }
        return nil
    }
}

