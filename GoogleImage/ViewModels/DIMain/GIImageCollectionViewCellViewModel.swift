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
    private let imageTitle: String
    private let imageLink: String
    
    // MARK: -Init
    
    init(imageURL: URL?, imageTitle: String, imageLink: String) {
        self.imageURL = imageURL
        self.imageTitle = imageTitle
        self.imageLink = imageLink
    }
    
    public var fetchImageTitle: String {
        return imageTitle
    }
    public var fetchImageLink: String {
        let imageLink = imageLink.trimmingCharacters(in: .urlHostAllowed)
        let components = imageLink.split(separator: "/")
        return String(components[0])
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
        hasher.combine(imageTitle)
        hasher.combine(imageLink)
    }
}
