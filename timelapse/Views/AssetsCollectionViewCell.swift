//
//  CollectionViewCell.swift
//  collection-view-test
//
//  Created by Nikita Simakov on 04.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit

class AssetsCollectionViewCell: UICollectionViewCell {
    
    let borderWidth: Int = 2
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = CGFloat( isSelected ? borderWidth : 0 )
        }
    }
    
}
