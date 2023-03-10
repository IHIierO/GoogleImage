//
//  GIListViewViewModel.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

//MARK: - GIListViewViewModelDelegate
protocol GIListViewViewModelDelegate: AnyObject {
    func didLoadInitialImages()
    func didLoadNewImages()
    func didSelectEpisode(_ image: ImagesResults, _ imageResult: [ImagesResults], indexPath: IndexPath)
    func didLoadMoreCharacters(with newIndexPaths: [IndexPath])
}

final class GIListViewViewModel: NSObject {
    
    public weak var delegate: GIListViewViewModelDelegate?
    
    private var isLoadingMoreImages = false
    
    public var imageResult: [ImagesResults] = [] {
        didSet {
            cellViewModels.removeAll()
            for result in imageResult {
                guard let title = result.title, let link = result.link else {
                    return
                }
                let viewModel = GIImageCollectionViewCellViewModel(imageURL: URL(string: result.thumbnail), imageTitle: title, imageLink: link)
                
                cellViewModels.append(viewModel)
            }
        }
    }
    
    private var cellViewModels: [GIImageCollectionViewCellViewModel] = []
    
    private var apiInfo: GIImageResponse? = nil
    
    /// Fetch initial set of images(100)
    public func fetchImages(searchString: String) {
        cellViewModels.removeAll()
        GIService.shared.execute(GIRequest(searchString: searchString), expexting: GIImageResponse.self) {
            [weak self] results in
            switch results {
            case .success(let responseModel):
                let response = responseModel
                self?.apiInfo = response
                self?.imageResult = response.images_results
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialImages()
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
                
                let originalCount = strongSelf.cellViewModels.count
                let newCount = moreResults.count
                let total = originalCount+newCount
                let startingIndex = total-newCount
                
                strongSelf.imageResult.append(contentsOf: moreResults)
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
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
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIImageCollectionViewCell.celIdentifier, for: indexPath) as? GIImageCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        
        //if indexPath.row >= cellViewModels.startIndex && indexPath.row < cellViewModels.endIndex {
            cell.configure(with: cellViewModels[indexPath.row])
        //}
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let image = imageResult[indexPath.row]
        delegate?.didSelectEpisode(image, imageResult, indexPath: indexPath)
    }
    
}

// MARK: - AdaptiveCollectionLayoutDelegate
extension GIListViewViewModel: AdaptiveCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= cellViewModels.startIndex && indexPath.row < cellViewModels.endIndex {
            guard let originalWidth = imageResult[indexPath.row].original_width, let originalHeight = imageResult[indexPath.row].original_height else {
                return AdaptiveCollectionConfig.cellBaseHeight
            }
            
            let imageWidth: Double = Double(originalWidth)
            let imageHeight: Double = Double(originalHeight)
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
        let queryString = query.replacingOccurrences(of: "%20", with: " ")
        let nextUrlString = GIRequest(searchString: queryString, ijn: (Int(nextIjn) ?? 0)+1).urlString
        guard let encodednextUrlString = nextUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        guard let url = URL(string: encodednextUrlString) else {
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
