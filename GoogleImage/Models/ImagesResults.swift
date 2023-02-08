//
//  ImagesResults.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

struct ImagesResults: Codable {
    let position: Int
    let thumbnail: String
    let source: String
    let title: String
    let link: String
    let original: String
    let original_width: Int
    let original_height: Int
    let is_product: Bool
}
