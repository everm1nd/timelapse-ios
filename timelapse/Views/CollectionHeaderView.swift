//
//  CollectionHeaderView.swift
//  collection-view-test
//
//  Created by Nikita Simakov on 04.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit
import Photos

class CollectionHeaderView: UICollectionReusableView {
        
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    var collection: PHAssetCollection! {
        didSet {
            self.label.text = titleFromCollection(collection)
        }
    }
    
    var section: Int! {
        didSet {
            self.selectButton.tag = section
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func titleFromCollection(_ collection: PHAssetCollection) -> String {
        // TODO: can be possibly extracted to utils module
        func stringFromDate(_ startDate: Date, toDate: Date) -> String {
            let formatter = DateIntervalFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            return formatter.string(from: startDate, to: toDate)
        }
        
        if let text = collection.localizedTitle {
            return text
        } else {
            return stringFromDate(collection.startDate!, toDate: collection.endDate!)
        }
    }
    
}
