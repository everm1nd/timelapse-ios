//
//  BluredImage.swift
//  timelapse
//
//  Created by Nikita Simakov on 20.09.16.
//  Copyright © 2016 Nikita Simakov. All rights reserved.
//

import UIKit

class BluredImage: UIImageView {
    
    var effectView:UIVisualEffectView!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        
        let blur:UIBlurEffect = UIBlurEffect(style: .light)
        effectView = UIVisualEffectView (effect: blur)
        
        // maybe this should be disabled by default
        // then it's better rename class to Blurable
        // and it's even better to make it probocol and just mix in required UIView
        addSubview(effectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = bounds
    }
    
    var blured: Bool = false {
        didSet {
            if blured {
                if !subviews.contains(effectView) {
                    addSubview(effectView)
                }
            } else {
                if subviews.contains(effectView) {
                    let index = subviews.index(of: effectView)
                    subviews[index!].removeFromSuperview()
                }
            }
        }
    }
    
}
