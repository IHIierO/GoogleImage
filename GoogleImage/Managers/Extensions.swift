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

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach({
            addArrangedSubview($0)
        })
    }
}

extension UICollectionView {
    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
}

extension UIDevice {
    
    static var isPhoneSE: Bool {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth == 320
    }
    
}
