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
    func didLoadMoreCharacters(with newIndexPaths: [IndexPath])
}

final class GIListViewViewModel: NSObject {
    
    public weak var delegate: GIListViewViewModelDelegate?
    
    private var isLoadingMoreImages = false
    
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
    
    private var apiInfo: GIImageResponse? = nil
    
    /// Fetch initial set of images(100)
    public func fetchImages() {
        GIService.shared.execute(GIRequest(searchString: " John Wick"), expexting: GIImageResponse.self) {
            [weak self] results in
            switch results {
            case .success(let responseModel):
                let response = responseModel
                self?.apiInfo = response
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
    
    /// Paginate if additional characters are needed
    public func fetchAdditionalImages(url: URL) {
        guard !isLoadingMoreImages else {
            return
        }
        isLoadingMoreImages = true
        guard let request = GIRequest(url: url) else {
            isLoadingMoreImages = false
            return
        }
        
        GIService.shared.execute(request,
                                 expexting: GIImageResponse.self) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.images_results
                strongSelf.apiInfo = responseModel
                
                let originalCount = strongSelf.imageResult.count
                let newCount = moreResults.count
                let total = originalCount+newCount
                let startingIndex = total-newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                strongSelf.imageResult.append(contentsOf: moreResults)
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadMoreCharacters(with: indexPathsToAdd)
                    strongSelf.isLoadingMoreImages = false
                }
            case .failure(let failure):
                print(String(describing: failure))
                strongSelf.isLoadingMoreImages = false
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool {
        return apiInfo != nil
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

// MARK: - AdaptiveCollectionLayoutDelegate
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

// MARK: - UIScrollViewDelegate
extension GIListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMoreImages,
              !cellViewModels.isEmpty,
              let query = apiInfo?.search_parameters.q,
              let nextIjn = apiInfo?.search_parameters.ijn else {
            return
        }
        
        let nextUrlString = GIRequest(searchString: query, ijn: Int(nextIjn)!+1).urlString
        guard let url = URL(string: nextUrlString) else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAdditionalImages(url: url)
            }
            timer.invalidate()
        }
    }
}
