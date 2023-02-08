//
//  SearchParameters.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

struct SearchParameters: Codable {
   let engine: String
   let q: String
   let google_domain: String
   let ijn: String
   let device: String
   let tbm: String
}
