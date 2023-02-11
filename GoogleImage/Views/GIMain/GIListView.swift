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
        allImages imageResult: [ImagesResults],
        indexPath: IndexPath
    )
}

final class GIListView: UIView {
    
    public weak var delegate: GIListViewDelegate?
    
    public let viewModel = GIListViewViewModel()
    
    public let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    public let collectionView: UICollectionView = {
       let layout = AdaptiveCollectionLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GIImageCollectionViewCell.self, forCellWithReuseIdentifier: GIImageCollectionViewCell.celIdentifier)
        return collectionView
    }()
    
    private let noResultsImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let noResultsLabel: UILabel = {
       let label = UILabel()
        label.text = "Enter a request"
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubviews(collectionView, spinner, noResultsImage, noResultsLabel)
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
        
        if let layout = collectionView.collectionViewLayout as? AdaptiveCollectionLayout {
            layout.delegate = viewModel
        }
        viewModel.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            noResultsImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsImage.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            noResultsImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            noResultsImage.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            
            noResultsLabel.topAnchor.constraint(equalTo: noResultsImage.bottomAnchor, constant: 10),
            noResultsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.topAnchor.constraint(equalTo: noResultsLabel.bottomAnchor, constant: 10),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

extension GIListView: GIListViewViewModelDelegate {
    func didLoadNewImages() {
        spinner.stopAnimating()
        noResultsImage.isHidden = false
        noResultsLabel.isHidden = false
        collectionView.isHidden = true
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.scrollsToTop = true
            self.collectionView.alpha = 0
        }
    }
    
    func didLoadInitialImages() {
        spinner.stopAnimating()
        noResultsImage.isHidden = true
        noResultsLabel.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.scrollsToTop = true
            self.collectionView.alpha = 1
        }
    }
    
    func didLoadMoreCharacters(with newIndexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: newIndexPaths)
        }
    }
    
    func didSelectEpisode(_ image: ImagesResults, _ imageResult: [ImagesResults], indexPath: IndexPath) {
        delegate?.giListView(self, didSelectEpisode: image, allImages: imageResult, indexPath: indexPath)
    }
    
}
