//
//  RToolbar.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-28.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import UIKit

typealias RToolbarHandler = (Int) -> Void

class RToolbar : UIView {
    let buttonImages = ["arrow-down", "arrow-up", "expand", "contract"]
    var handler:RToolbarHandler?

    init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.8, alpha: 0.9)
        let itemWidth = frame.width/CGFloat(buttonImages.count)
        
        var x = 0 as CGFloat
        var i = 0
        for one in buttonImages {
            let button = UIButton()
            button.setImage(UIImage(named:one), forState: .Normal)
            button.frame = CGRectMake(x, 0, itemWidth, frame.height)
            button.addTarget(self, action: "buttonClick:", forControlEvents: .TouchUpInside)
            self.addSubview(button)
            button.tag = i

            x += itemWidth
            i++
        }
    }
    
    func buttonClick(button:UIButton) {

        if handler {

            handler!(button.tag)
        }
    }
    
}
