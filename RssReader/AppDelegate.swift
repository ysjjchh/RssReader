//
//  AppDelegate.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-22.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import UIKit

let rss_sources = ["AppShopper.com":"http://appshopper.com/feed/?mode=featured&amp;filter=price&amp;type=free",
    "掘图志":"http://feeds.juetuzhi.cn/",
    "Engadget 中国版":"http://cn.engadget.com/rss.xml",
    "FT中文网_英国《金融时报》(Financial Times)":"http://www.ftchinese.com/rss/feed",
    "TECH2IPO创见":"http://tech2ipo.feedsportal.com/c/34822/f/641707/index.rss",
    "有意思吧":"http://www.u148.net/rss/"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var _slidingViewController: ECSlidingViewController?
    let rootController = ViewController()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        self.initData()
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.backgroundColor = UIColor.whiteColor()

        let navigation = UINavigationController(rootViewController: rootController)
        navigation.navigationBar.translucent = false
       
        _slidingViewController = ECSlidingViewController(topViewController: navigation)
        
        let leftController = LeftController(style: .Grouped)
        _slidingViewController!.underLeftViewController = leftController
        _slidingViewController!.anchorLeftRevealAmount = 250.0
        
        leftController.view.layer.borderWidth     = 10;
        leftController.view.layer.backgroundColor = UIColor(white:0.9, alpha:1.0).CGColor
        leftController.view.layer.borderColor     = UIColor(white:0.9, alpha:1.0).CGColor
        leftController.edgesForExtendedLayout     = .Top | .Bottom | .Left; // don't go under the top view
        
        leftController.selectedHandler = { [weak self] item in
            self!._slidingViewController!.resetTopViewAnimated(true)
            self!.rootController.startRequest(item)
        }
        
        let leftButton = UIBarButtonItem(barButtonSystemItem:.Bookmarks, target:self, action:"anchorLeft")
        rootController.navigationItem.leftBarButtonItem = leftButton
        
        window!.rootViewController = _slidingViewController
        
        window!.makeKeyAndVisible()
        return true
    }
    
    func anchorLeft() {
        if .Centered != _slidingViewController!.currentTopViewPosition {
            _slidingViewController!.resetTopViewAnimated(true)
        } else {
            _slidingViewController!.anchorTopViewToRightAnimated(true)
        }
        
    }
    
    func initData() {
        if Config.shared().fisrtRun {
            for one in rss_sources {
                let channel = RssChannel()
                channel.name = one.0
                channel.url = one.1
                channel.save()
            }
            
            Config.shared().fisrtRun = false
            Config.shared().save()
        }
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

