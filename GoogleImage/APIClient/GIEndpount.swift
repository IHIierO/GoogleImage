//
//  GIEndpount.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

/// Represents unique API endpoints
@frozen enum GIEndpoint: String, CaseIterable, Hashable {
    /// Endpoint to get character info
    case apple = "apple"
    /// Endpoint to get location info
    case location
    /// Endpoint to get episode info
    case episode
}
