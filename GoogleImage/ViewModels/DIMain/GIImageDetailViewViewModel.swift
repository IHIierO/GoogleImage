//
//  GIImageDetailViewViewModel.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

final class GIImageDetailViewViewModel {
    
    public var image: ImagesResults
    
    init(image: ImagesResults) {
        self.image = image
    }
    
    public func fethImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: image.thumbnail) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        GIImageLoader.shared.dowloadImage(url, completion: completion)
    }
}
