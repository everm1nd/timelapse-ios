//
//  AssetsStorage.swift
//  collection-view-test
//
//  Created by Nikita Simakov on 14.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import Foundation
import Photos

class AssetsStorage {
    // THIS IS A SINGLETON, 👶
    static let sharedInstance = AssetsStorage()
    private init() {}
    
    private var assets = [PHAsset]()
    
    public func add(_ element: PHAsset) {
        if !assets.contains(element) {
            debugPrint(element.creationDate)
            assets.append(element)
        }
    }
    
    public func remove(_ element: PHAsset) {
        if let index = assets.index(of: element) {
            assets.remove(at: index)
        }
    }
    
    public func get(_ index: Int) -> PHAsset {
        return assets[index]
    }
    
    public func sorted() -> [PHAsset] {
        return assets.sorted {
            $0.creationDate! < $1.creationDate!
        }
    }
    
    var count: Int {
        get {
            return assets.count
        }
    }
}
