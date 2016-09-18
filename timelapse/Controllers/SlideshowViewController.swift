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
    
    var assets = [PHAsset]()
    var imageManager: PHImageManager!
    var imageIndex = 0;
    var imageSize: CGSize!
    
    var timer: Timer!
    
    var cachedImages = [PHAsset: UIImage]()
    
    let storage = AssetsStorage.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        assets = storage.sorted()
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
        
        for asset in assets { fetchImageFor(asset) }
    }
    
    func fetchImageFor(_ asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false // TODO: improve this with some kind of promise
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true // TODO: handle this carefully, because it's slow
        
        self.imageManager.requestImage(for: asset,
            targetSize: self.imageSize,
            contentMode: .aspectFill,
            options: options,
            resultHandler: {
                image, info in
                self.cachedImages[asset] = (image as UIImage?)!
        })
    }
    
    func updateImageView() -> Void {
        print("\(imageIndex + 1)/\(assets.count)")
        let asset = assets[imageIndex]
        let image = cachedImages[asset]
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

