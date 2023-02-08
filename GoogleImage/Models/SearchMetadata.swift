//
//  SearchMetadata.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

struct SearchMetadata: Codable {
   let id: String
   let status: String
   let json_endpoint: String
   let created_at: String
   let processed_at: String
   let google_url: String
   let raw_html_file: String
   let total_time_taken: Double
}
