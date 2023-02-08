//
//  GIMainViewController.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

final class GIMainViewController: UIViewController {
    
    private let giListView = GIListView()
    
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Enter a request"
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

