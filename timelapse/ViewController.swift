//
//  ViewController.swift
//  timelapse
//
//  Created by Nikita Simakov on 01.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    
    var images: PHFetchResult!
    var imageManager: PHImageManager!
    var imageIndex = 0;
    var imageSize: CGSize!
    
    var timer: NSTimer!
    
    var cachedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        images = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        imageManager = PHImageManager()
        warmupCache()
        updateImageView() // update it once, becasue timer first fires after N miliseconds
        startTimer()
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
        
        images.enumerateObjectsUsingBlock(fetchImage)
    }
    
    func fetchImage(object: AnyObject, index: Int, _: UnsafeMutablePointer<ObjCBool>) {
        let asset = object as! PHAsset
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        
        self.imageManager.requestImageForAsset(asset,
            targetSize: self.imageSize,
            contentMode: .AspectFill,
            options: options,
            resultHandler: {
                image, info in
                debugPrint(image)
                self.cachedImages.append((image as UIImage?)!)
        })
    }
    
    func updateImageView() -> Void {
        print("\(imageIndex + 1)/\(images.count)")
        let image = cachedImages[imageIndex]
        self.photoImageView.image = image
        imageIndex = nextImageIndex()
    }
    
    func nextImageIndex() -> Int {
        return ( imageIndex + 1 ) % ( images.count )
    }
    
    @IBAction func imageTap(sender: UITapGestureRecognizer) {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateImageView", userInfo: nil, repeats: true)
    }

}

