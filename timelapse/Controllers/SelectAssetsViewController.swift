//
//  CollectionViewController.swift
//  collection-view-test
//
//  Created by Nikita Simakov on 04.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class SelectAssetsViewController: UICollectionViewController {
    
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
    
    var moments = [Moment]()
    var imageManager: PHCachingImageManager!
    
    let imageSize = CGSize(width: 150, height: 150)
    let CellsPerRow = CGFloat(10)
    
    let storage = AssetsStorage.sharedInstance
    
//    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        let side = self.view.frame.width / CellsPerRow
//        layout.itemSize = self.view.frame.size
        layout.itemSize = CGSize(width: side, height: side)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.imageManager = PHCachingImageManager()
        
        collectionView?.allowsMultipleSelection = true

        warmupImages()
    }
    
//    func photoForIndexPath(indexPath: NSIndexPath) -> UIImage {
//        debugPrint(indexPath)
//        return moments[indexPath.section].photos[indexPath.row]
//    }
    
    func assetForIndexPath(_ indexPath: IndexPath) -> PHAsset {
        return moments[indexPath.section].assets[indexPath.row]
    }
    
    func warmupImages() -> Void {
        moments = [Moment]() // reset an array.
                                 // TODO: better use deinitialize, right?
        
        let collections = PHAssetCollection.fetchMoments(with: nil)
        collections.enumerateObjects({ collection, momentIndex, _ in
            self.moments.append(Moment(collection: collection ))
        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return moments.count
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return moments[section].assets.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsIn(section: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetsCollectionViewCell
        
        let asset = assetForIndexPath(indexPath)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        imageManager.requestImage(
            for: asset,
            targetSize: self.imageSize,
            contentMode: .aspectFill,
            options: options,
            resultHandler: {
                image, info in
                cell.imageView.image = image
            }
        )
    
        return cell
    }
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
//        cell.layer.borderWidth = 5
//        cell.layer.borderColor = UIColor.redColor().CGColor
//        debugPrint("cell selected: ", cell)
//    }
//    
//    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
//        cell.layer.borderWidth = 0
//        cell.layer.borderColor = UIColor.redColor().CGColor
//    }
    
    
//    // set cell size
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                                                   at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                      withReuseIdentifier: "CollectionHeaderView",
                                                                      for: indexPath)
                    as! CollectionHeaderView
            // headerView.label.text = moments[indexPath.section].collection!.localizedTitle
            headerView.collection = moments[indexPath.section].collection
            headerView.section = indexPath.section
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addAssetWith(indexPath: indexPath)
    }
    
    private func addAssetWith(indexPath: IndexPath) {
        let asset = assetForIndexPath(indexPath)
        storage.add(asset)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        removeAssetWith(indexPath: indexPath)
    }
    
    func removeAssetWith(indexPath: IndexPath) {
        let asset = assetForIndexPath(indexPath)
        storage.remove(asset)
    }
    
    @IBAction func selectMomentButtonClicked(_ sender: UIButton) {
        let section = sender.tag
        let cells = cellsIn(section: section)
        let allSelectedFlag = allSelected(cells: cells)
        
        for (row, _) in cells.enumerated() {
            let indexPath = IndexPath(row: row, section: section)
            if allSelectedFlag {
                removeAssetWith(indexPath: indexPath)
                collectionView?.deselectItem(at: indexPath, animated: true)
            } else {
                addAssetWith(indexPath: indexPath)
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
        }
    }
    
    func cellsIn(section: Int) -> [UICollectionViewCell] {
        return (0..<numberOfItemsIn(section: section)).map {
            collectionView?.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: IndexPath(row: $0, section: section)) as! AssetsCollectionViewCell
        }
    }
    
    func allSelected(cells: [UICollectionViewCell]) -> Bool {
        return !cells.map { (cell: UICollectionViewCell) -> Bool in
            return cell.isSelected
        }.contains(false)
    }

}
