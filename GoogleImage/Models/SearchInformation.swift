//
//  SearchInformation.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

struct SearchInformation: Codable {
    let image_results_state: String?
    let query_displayed: String?
    let showing_results_for: String?
    let spelling_fix: String?
    let menu_items: [MenuItems]?
}
