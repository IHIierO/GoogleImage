//
//  GIImageDetailViewController.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit
import StoreKit
import SafariServices

class GIImageDetailViewController: UIViewController {
    
    private var viewModel: GIImageDetailViewViewModel
    
    private let detailView: GIImageDetailView
    
    // MARK: - init
    init (viewModel: GIImageDetailViewViewModel) {
        self.viewModel = viewModel
        self.detailView = GIImageDetailView(frame: .zero, viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeStyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setConstraints()
    }
    
    private func setupController() {
        view.addSubview(detailView)
        view.backgroundColor = .systemBackground
        detailView.delegate = self
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}


extension GIImageDetailViewController: GIImageDetailViewDelegate {
    func goToPrev(_ viewModel: GIImageDetailViewViewModel) {
       let image = viewModel.imageResult.first(where: {
            $0.position == viewModel.image.position - 1
       })
        guard let prevImage = image else {
           return
       }
        viewModel.image = prevImage
        detailView.getImage()
    }
    
    func goToNext(_ viewModel: GIImageDetailViewViewModel) {
        let image = viewModel.imageResult.first(where: {
             $0.position == viewModel.image.position + 1
        })
         guard let nextImage = image else {
            return
        }
         viewModel.image = nextImage
         detailView.getImage()
    }
    
    func goToOriginal(_ viewModel: GIImageDetailViewViewModel) {
        guard Thread.current.isMainThread else {
            return
        }
        guard let link = viewModel.image.link else {
            return 
        }
        if let url = URL(string: link) {
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true)
        }
    }
}
