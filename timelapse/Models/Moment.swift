//
//  Moment.swift
//  timelapse
//
//  Created by Nikita Simakov on 18.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import Foundation
import Photos

class Moment {
    var assets = [PHAsset]()
    var collection: PHAssetCollection?
    
    init(collection: PHAssetCollection) {
        self.collection = collection
        
        let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        fetchResult.enumerateObjects({ (asset, _, _) in
            self.assets.append(asset )
        })
    }
}
