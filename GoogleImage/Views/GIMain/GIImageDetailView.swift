//
//  GIImageDetailView.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

protocol GIImageDetailViewDelegate: AnyObject {
    func goToOriginal(_ viewModel: GIImageDetailViewViewModel)
    func goToPrev(_ viewModel: GIImageDetailViewViewModel)
    func goToNext(_ viewModel: GIImageDetailViewViewModel)
}

class GIImageDetailView: UIView {
    
    public weak var delegate: GIImageDetailViewDelegate?
    public var viewModel: GIImageDetailViewViewModel
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let goToOriginalButton: UIButton = {
       let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Original"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let goToNextButton: UIButton = {
       let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Next"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let goToPrevButton: UIButton = {
       let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Prev"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    // MARK: - Init
    init(frame: CGRect, viewModel: GIImageDetailViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(imageView,buttonsStack)
        setConstraints()
        setupButtonStack()
        getImage()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtonStack() {
        buttonsStack.backgroundColor = .secondarySystemBackground
        buttonsStack.layer.cornerRadius = 8
        buttonsStack.addArrangedSubviews(goToPrevButton, goToOriginalButton, goToNextButton)
        [goToPrevButton, goToOriginalButton, goToNextButton].forEach({
            $0.configuration?.baseBackgroundColor = .tertiarySystemBackground
            $0.configuration?.baseForegroundColor = .label
        })
        goToOriginalButton.addTarget(self, action: #selector(goToOriginal), for: .touchUpInside)
        goToPrevButton.addTarget(self, action: #selector(goToPrev), for: .touchUpInside)
        goToNextButton.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
    }
    
    @objc private func goToOriginal() {
        delegate?.goToOriginal(viewModel)
    }
    @objc private func goToPrev() {
        delegate?.goToPrev(viewModel)
    }
    @objc private func goToNext() {
        delegate?.goToNext(viewModel)
    }
    
    public func getImage() {
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
            
            buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -10),
            buttonsStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65),
            buttonsStack.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            buttonsStack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
