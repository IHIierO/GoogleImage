//
//  GIMainViewController.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

final class GIMainViewController: UIViewController {
    
    private let giListView = GIListView()
    
    private let viewModel = GIListViewViewModel()
    
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Enter a request"
        searchBar.returnKeyType = .search
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    // MARK: - LifeStyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setConstraints()
    }

    private func setupViewController() {
        view.backgroundColor = .systemBackground
        title = "Google Image"
        view.addSubviews(giListView, searchBar)
        giListView.delegate = self
        searchBar.delegate = self
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            giListView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            giListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            giListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            giListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension GIMainViewController: GIListViewDelegate {
    func giListView(_ giListView: GIListView, didSelectEpisode image: ImagesResults, allImages imageResult: [ImagesResults]) {
        let viewModel = GIImageDetailViewViewModel(image: image)
        viewModel.imageResult = imageResult
        let detailVC = GIImageDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension GIMainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        giListView.viewModel.delegate?.didLoadNewImages()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
         giListView.viewModel.fetchImages(searchString: searchText)
    }
}
