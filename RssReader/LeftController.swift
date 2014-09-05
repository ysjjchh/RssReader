//
//  LeftController.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-26.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import UIKit

typealias ItemSelectedHandler = (RssChannel) -> Void

class LeftController: UITableViewController {
    
    var selectedHandler:ItemSelectedHandler?
    var _sourceArray = [RssChannel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _sourceArray = RssChannel.allObjects() as [RssChannel]
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 50
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sourceArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if selectedHandler {
            let item = _sourceArray[indexPath.row]
            selectedHandler!(item)
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {

        cell.textLabel.text = _sourceArray[indexPath.row].name
        cell.textLabel.font = UIFont.systemFontOfSize(15.0)
        cell.textLabel.numberOfLines = 0
    }

}





