//
//  RssChannel.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-28.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import Foundation

class RssChannel: SQLitePersistentObject {
    var rssId:NSString?
    var name:NSString?
    var url:NSString?
    
    init() {
        super.init()
        
        rssId = self.createUuid()
    }
    
    func createUuid() -> NSString {
    
        // Create universally unique identifier (object)
        let uuidObject = CFUUIDCreate(kCFAllocatorDefault)
        
        // Get the string representation of CFUUID object.
        let uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuidObject)
        
        return uuidStr
    }
}