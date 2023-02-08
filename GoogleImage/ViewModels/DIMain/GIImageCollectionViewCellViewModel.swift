//
//  GIImageCollectionViewCellViewModel.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

protocol GIImagesResultsDataRender {
    var position: Int {get}
    var thumbnail: String {get}
    var original: String {get}
}

final class GIImageCollectionViewCellViewModel: Hashable, Equatable {
    
    private let imageURL: URL?
    
    // MARK: -Init
    
    init(imageURL: URL?) {
        self.imageURL = imageURL
    }
    
    public func fethImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = imageURL else {
            completion(.failure(URLError(.badURL)))
            return
        }
        GIImageLoader.shared.dowloadImage(url, completion: completion)
    }
    
    // MARK: - Hashable
    static func == (lhs: GIImageCollectionViewCellViewModel, rhs: GIImageCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageURL)
    }
}
