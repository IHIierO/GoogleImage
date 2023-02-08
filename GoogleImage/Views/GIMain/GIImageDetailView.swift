//
//  GIImageDetailView.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

protocol GIImageDetailViewDelegate: AnyObject {
    func goToOriginal(_ viewModel: GIImageDetailViewViewModel)
}

class GIImageDetailView: UIView {
    
    public weak var delegate: GIImageDetailViewDelegate?
    private let viewModel: GIImageDetailViewViewModel
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let goToOriginalButton: UIButton = {
       let button = UIButton()
        button.configuration = .plain()
        button.configuration?.title = "Go to original"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(frame: CGRect, viewModel: GIImageDetailViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(imageView,goToOriginalButton)
        setConstraints()
        getImage()
        goToOriginalButton.addTarget(self, action: #selector(goToOriginal), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func goToOriginal() {
        delegate?.goToOriginal(viewModel)
    }
    
    private func getImage() {
        viewModel.fethImage { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self?.imageView.image = image
                }
            case .failure(let error):
                print(String(describing: error))
                break
            }
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            goToOriginalButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -10),
            goToOriginalButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
