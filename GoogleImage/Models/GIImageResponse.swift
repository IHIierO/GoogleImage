//
//  GIImageResponse.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

struct GIImageResponse: Codable {
    
    let search_metadata: SearchMetadata
    let search_parameters: SearchParameters
    let search_information: SearchInformation
    let suggested_searches: [SuggestedSearches]?
    let images_results: [ImagesResults]
}

