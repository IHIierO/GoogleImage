//
//  GIListViewViewModel.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

//MARK: - GIListViewViewModelDelegate
protocol GIListViewViewModelDelegate: AnyObject {
    func didSelectEpisode(_ image: ImagesResults, _ imageResult: [ImagesResults])
}

final class GIListViewViewModel: NSObject {
    
    public weak var delegate: GIListViewViewModelDelegate?
    
    private var imageResult: [ImagesResults] = [] {
        didSet {
            for result in imageResult {
                guard let title = result.title, let link = result.link else {
                    return
                }
                let viewModel = GIImageCollectionViewCellViewModel(imageURL: URL(string: result.thumbnail), imageTitle: title, imageLink: link)
                if !cellViewModels.contains(viewModel){
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [GIImageCollectionViewCellViewModel] = []
    
   // private var apiInfo: RMGetAllEpisodesResponse.Info? = nil
    
    /// Fetch initial set of images(100)
    public func fetchImages() {
        GIService.shared.execute(GIRequest(searchString: " John Wick"), expexting: GIImageResponse.self) {
            [weak self] results in
            switch results {
            case .success(let responseModel):
                let response = responseModel
               // let info = responseModel.info
                self?.imageResult = response.images_results
                
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
        
        if indexPath.row >= cellViewModels.startIndex && indexPath.row < cellViewModels.endIndex {
            cell.configure(with: cellViewModels[indexPath.row])
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let image = imageResult[indexPath.row]
        delegate?.didSelectEpisode(image, imageResult)
    }
    
}

extension GIListViewViewModel: AdaptiveCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= cellViewModels.startIndex && indexPath.row < cellViewModels.endIndex {
            guard  imageResult[indexPath.row].original_width != nil , imageResult[indexPath.row].original_height != nil else {
                return AdaptiveCollectionConfig.cellBaseHeight
            }
            
            let imageWidth: Double = Double(imageResult[indexPath.row].original_width!)
            let imageHeight: Double = Double(imageResult[indexPath.row].original_height!)
            let ratio: Double = imageWidth / (imageHeight + 70)
            let height = collectionView.widestCellWidth / 2 / ratio
            return CGFloat(height)
        }
        return AdaptiveCollectionConfig.cellBaseHeight
    }
}
