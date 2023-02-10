//
//  GIListView.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

protocol GIListViewDelegate: AnyObject {
    func giListView(
        _ giListView: GIListView,
        didSelectEpisode image: ImagesResults,
        allImages imageResult: [ImagesResults]
    )
}

final class GIListView: UIView {
    
    public weak var delegate: GIListViewDelegate?
    
    public let viewModel = GIListViewViewModel()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let collectionView: UICollectionView = {
       let layout = AdaptiveCollectionLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GIImageCollectionViewCell.self, forCellWithReuseIdentifier: GIImageCollectionViewCell.celIdentifier)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        addSubviews(collectionView, spinner)
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
        
        if let layout = collectionView.collectionViewLayout as? AdaptiveCollectionLayout {
            layout.delegate = viewModel
        }
        //viewModel.fetchImages(searchString: "John Wick")
        viewModel.delegate = self
        spinner.startAnimating()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension GIListView: GIListViewViewModelDelegate {
    func didLoadNewImages() {
        spinner.startAnimating()
        collectionView.isHidden = true
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 0
        }
    }
    
    func didLoadInitialImages() {
        spinner.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
    
    func didLoadMoreCharacters(with newIndexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: newIndexPaths)
        }
    }
    
    func didSelectEpisode(_ image: ImagesResults, _ imageResult: [ImagesResults]) {
        delegate?.giListView(self, didSelectEpisode: image, allImages: imageResult)
    }
    
}
