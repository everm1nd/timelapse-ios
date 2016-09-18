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
        
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = .typeUserLibrary // should fix a problem with iCloud data for first time
        
        let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        fetchResult.enumerateObjects({ (asset, _, _) in
            // TODO: move filtration responsability to source of assets (e.g. controller)
            if (asset.mediaType == .image) {
                self.assets.append(asset)
            }
        })
    }
}
