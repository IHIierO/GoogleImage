//
//  Extensions.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}
