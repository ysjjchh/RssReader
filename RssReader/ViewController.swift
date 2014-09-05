//
//  ViewController.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-22.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, MWFeedParserDelegate, DetailControllerDataSource {
    
    var items = [MWFeedItem]()
    var rssChannel:RssChannel?
    var isInit = true
    var currentIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.addPullToRefreshWithActionHandler() { [weak self] in
            self!.request(self!.rssChannel!.url)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInit {
            let firstRss = RssChannel.findFirstByCriteria("") as? RssChannel
            if firstRss {
                rssChannel = firstRss
                
                self.tableView.triggerPullToRefresh()
            }
            
            isInit = false
        }

    }
    
    func startRequest(channel:RssChannel?) {
        rssChannel = channel
        self.tableView.triggerPullToRefresh()
    }

    func request(url:String?) {

        if url {

            let URL = NSURL(string: url)
            let feedParser = MWFeedParser(feedURL: URL);
            feedParser.delegate = self
            feedParser.connectionType = ConnectionTypeAsynchronously
            feedParser.parse()
        }
    }
    
    func feedParserDidStart(parser: MWFeedParser) {

    }
    
    func feedParserDidFinish(parser: MWFeedParser) {

        self.items = MWFeedItem.findByCriteria2("WHERE rss_id='\(rssChannel!.rssId!)' ORDER BY identifier DESC") as [MWFeedItem]
        self.tableView.pullToRefreshView.stopAnimating()
        self.tableView.reloadData()
    }
    
    func feedParser(parser: MWFeedParser, didParseFeedInfo info: MWFeedInfo) {
        println(info)
        self.title = info.title
    }
    
    func feedParser(parser: MWFeedParser, didParseFeedItem item: MWFeedItem) {
        item.rssId = rssChannel!.rssId
        let stored = MWFeedItem.findByCriteria2("WHERE identifier='\(item.identifier)' AND rss_id='\(item.rssId)'")
        if stored.count > 0 {

        } else {
            item.isUnread = true
            item.save()
            
            self.items.append(item)
        }
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 60
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "FeedCell")
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        
        let item = self.items[indexPath.row] as MWFeedItem
        
        let detail = DetailController()
        detail.delegate = self
        
        if item.content {
            detail.htmlContent = item.content
        } else {
            detail.htmlContent = item.summary
        }
        
        if item.isUnread {
            item.isUnread = false
            item.save()
            
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
        
        self.navigationController.pushViewController(detail, animated: true)
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as MWFeedItem
        cell.textLabel.text = item.title
        cell.textLabel.numberOfLines = 0
        
        if item.isUnread {
            cell.textLabel.font = UIFont.boldSystemFontOfSize(16)
            cell.textLabel.textColor = UIColor.blackColor()
        } else {
            cell.textLabel.font = UIFont.systemFontOfSize(16.0)
            cell.textLabel.textColor = UIColor(white:0.15, alpha: 1)
        }
    }
    
    func nextContent() -> String? {
        if self.currentIndex + 1 < self.items.count {
            self.currentIndex++
            
            let item = self.items[self.currentIndex] as MWFeedItem
            
            if item.isUnread {
                item.isUnread = false
                item.save()
                
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.currentIndex, inSection: 0)],
                    withRowAnimation: .None)
            }
            
            if item.content {
                return item.content
            } else {
                return item.summary
            }
        }
        
        return nil
    }
    
    func previousContent() -> String? {
        if self.currentIndex - 1 >= 0 {
            self.currentIndex--
            let item = self.items[self.currentIndex] as MWFeedItem
            
            if item.isUnread {
                item.isUnread = false
                item.save()
                
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.currentIndex, inSection: 0)],
                    withRowAnimation: .None)
            }
            
            if item.content {
                return item.content
            } else {
                return item.summary
            }
        }
        
        return nil
    }
}












