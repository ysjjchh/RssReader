//
//  CXLazyImageView.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-27.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import UIKit

class CXLazyImageView : DTLazyImageView, CXPhotoProtocol {
    
    func underlyingImage() -> UIImage? {
        return self.image
    }
    
    func loadUnderlyingImageAndNotify() {
        if self.image {
            self.notifyImageDidFinishLoad()
        }
    }
    
    func unloadUnderlyingImage() {

    }
    
    func notifyImageDidFinishLoad() {
        dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(NFCXPhotoImageDidFinishLoad, object:self)
            }
    }
    
    override func _notifyDelegate() {
        super._notifyDelegate()
        self.notifyImageDidFinishLoad()
    }
}