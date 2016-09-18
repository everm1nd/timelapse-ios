//
//  CollectionViewController.swift
//  collection-view-test
//
//  Created by Nikita Simakov on 04.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "AssetCell"

class SelectAssetsViewController: UICollectionViewController {
    
    var moments = [Moment]()
    var imageManager: PHCachingImageManager!
    
    @IBInspectable var imageSize: CGSize = CGSize(width: 150, height: 150)
    @IBInspectable var CellsPerRow: CGFloat = CGFloat(10)
    
    let storage = AssetsStorage.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCellsView()
        
        self.imageManager = PHCachingImageManager()
        collectionView?.allowsMultipleSelection = true

        fetchMoments()
    }
    
    // TODO: fix this function
    func authorizeForPhotosAccess(success: @escaping () -> Void, failure: (() -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
            switch (status) {
            case .authorized:
                success()
                break;
                
            default:
                if (failure != nil) {
                    failure!()
                } else {
                    debugPrint("Photos authorization declined.")
                    exit(0)
                }
                break;
            }
        })
    }
    
    private func configureCellsView() {
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        let margin = layout.minimumLineSpacing
        // cells a square, so we calc only one side instead of H&W
        // we subtract magrin to calculate width without air
        let side = self.view.frame.width / CellsPerRow - margin
        
        layout.itemSize = CGSize(width: side, height: side)
    }
    
    func assetForIndexPath(_ indexPath: IndexPath) -> PHAsset {
        return moments[indexPath.section].assets[indexPath.row]
    }
    
    func fetchMoments() -> Void {
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
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                                                   at indexPath: IndexPath) -> UICollectionReusableView {
        // TODO: check if you can simplify this function
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                      withReuseIdentifier: "AssetsCollectionHeaderView",
                                                                      for: indexPath)
                    as! AssetsCollectionHeaderView
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
