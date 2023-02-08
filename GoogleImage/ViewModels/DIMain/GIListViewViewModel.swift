//
//  GIListViewViewModel.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

final class GIListViewViewModel: NSObject {
    
    private var imageResult: [ImagesResults] = [] {
        didSet {
            for result in imageResult {
                let viewModel = GIImageCollectionViewCellViewModel(imageURL: URL(string: result.thumbnail))
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [GIImageCollectionViewCellViewModel] = []
    
   // private var apiInfo: RMGetAllEpisodesResponse.Info? = nil
    
    /// Fetch initial set of images(100)
    public func fetchImages() {
        GIService.shared.execute(.listAppleRequest, expexting: GIImageResponse.self) {
            [weak self] results in
            switch results {
            case .success(let responseModel):
                let response = responseModel
               // let info = responseModel.info
                self?.imageResult = response.images_results
                print("Image Results Count: - \(response.images_results.count)")
                //self?.apiInfo = info
                DispatchQueue.main.async {
                    //self?.delegate?.didLoadInitialEpisode()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
}

// MARK: - CollectionView Delegates
extension GIListViewViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIImageCollectionViewCell.celIdentifier, for: indexPath) as? GIImageCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let width = (bounds.width / 4) - 10
        return CGSize(width: width, height: width)
    }
    
}
