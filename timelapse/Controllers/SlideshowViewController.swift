//
//  ViewController.swift
//  timelapse
//
//  Created by Nikita Simakov on 01.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit
import Photos

class SlideshowViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    
    var assets: PHFetchResult<PHAsset>!
    var imageManager: PHImageManager!
    var imageIndex = 0;
    var imageSize: CGSize!
    
    var timer: Timer!
    
    var cachedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        assets = PHAsset.fetchAssets(with: .image, options: nil)
        imageManager = PHImageManager()
        warmupCache()
        updateImageView() // update it once, becasue timer first fires after N miliseconds
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func warmupCache() -> Void {
        let frame = photoImageView.frame.size
        let sizeFactor = CGFloat(2) // without this photos looks blurred on retina
        self.imageSize = CGSize(width: frame.width * sizeFactor,
            height: frame.height * sizeFactor)
        
        assets.enumerateObjects(fetchImage)
    }
    
    func fetchImage(_ object: AnyObject, index: Int, _: UnsafeMutablePointer<ObjCBool>) {
        let asset = object as! PHAsset
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        self.imageManager.requestImage(for: asset,
            targetSize: self.imageSize,
            contentMode: .aspectFill,
            options: options,
            resultHandler: {
                image, info in
                self.cachedImages.append((image as UIImage?)!)
        })
    }
    
    func updateImageView() -> Void {
        print("\(imageIndex + 1)/\(assets.count)")
        let image = cachedImages[imageIndex]
        self.photoImageView.image = image
        imageIndex = nextImageIndex()
    }
    
    func nextImageIndex() -> Int {
        return ( imageIndex + 1 ) % ( assets.count )
    }
    
    @IBAction func imageTap(_ sender: UITapGestureRecognizer) {
        toggleTimer()
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(SlideshowViewController.updateImageView), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        self.timer = nil
    }
    
    func toggleTimer() {
        (self.timer != nil) ? stopTimer() : startTimer()
    }

}

