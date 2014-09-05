//
//  Config.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-28.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import Foundation

class Config : SQLitePersistentObject {
    struct MySingleton {
        static var instance: Config!
        static var once: dispatch_once_t = 0
    }
    
    class func shared() -> Config {
        dispatch_once(&MySingleton.once, {
            
                let stored = Config.allObjects()
                if stored.count > 0 {
                    MySingleton.instance = stored[0] as Config
                } else {
                    MySingleton.instance = Config()
                }
            
            })
        
        return MySingleton.instance
    }
    
    var fisrtRun:Bool = true
    
}