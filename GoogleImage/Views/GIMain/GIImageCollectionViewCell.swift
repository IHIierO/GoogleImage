//
//  GIImageCollectionViewCell.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

/// Single cell for a image
final class GIImageCollectionViewCell: UICollectionViewCell {
    static let celIdentifier = "GIImageCollectionViewCell"
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    public let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let imageLink: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Website"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let imageTitle: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(imageView, imageLink, imageTitle, spinner)
        setConstraints()
        setupLayer()
        spinner.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupLayer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageTitle.text = nil
        imageLink.text = nil
    }
    
    private func setupLayer() {
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.cornerRadius = 4
        contentView.layer.shadowOffset = CGSize(width: -4, height: 4)
        contentView.layer.shadowOpacity = 0.3
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            imageTitle.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageLink.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            imageLink.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageLink.bottomAnchor.constraint(equalTo: imageTitle.topAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageLink.topAnchor),
            
            spinner.topAnchor.constraint(equalTo: contentView.topAnchor),
            spinner.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            spinner.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            spinner.bottomAnchor.constraint(equalTo: imageLink.topAnchor),
        ])
    }
    
    public func configure(with viewModel: GIImageCollectionViewCellViewModel) {
        viewModel.fethImage { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self?.imageView.image = image
                    self?.spinner.stopAnimating()
                }
            case .failure(let error):
                print(String(describing: error))
                break
            }
        }
        imageTitle.text = viewModel.fetchImageTitle
        imageLink.text = viewModel.fetchImageLink
    }
}
