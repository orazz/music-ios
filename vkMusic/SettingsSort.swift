//
//  SettingsList.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/15/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit

class SettingsSort: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sortirovka = ["Goşulan wagty boýunça", "Uzynlygy boýunça", "Meşhurlygy boýunça"]
    var counts = ["30 sany", "50 sany", "100 sany", "200 sany", "300 sany"]
    var settingType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(settingType)
        self.preferredContentSize = CGSizeMake(320,150)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"Cell")
    }
}

extension SettingsSort: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        switch settingType {
        case 0:
            return sortirovka.count
        case 1:
            return counts.count
        default:break
        }
        return result
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if (settingType == 0)
        {
            let sort = NSUserDefaults.standardUserDefaults().integerForKey("sort")
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:indexPath) as! UITableViewCell
            cell.textLabel?.text = sortirovka[indexPath.row]
            cell.accessoryType = (sort == row ?
                .Checkmark :
                .None)
            return cell
        }else{
            let count = NSUserDefaults.standardUserDefaults().integerForKey("count")
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:indexPath) as! UITableViewCell
            cell.textLabel?.text = counts[indexPath.row]
            cell.accessoryType = (count == row ?
                .Checkmark :
                .None)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if settingType == 0 {
                NSUserDefaults.standardUserDefaults().setInteger(row, forKey:"sort")
                tableView.reloadData()
            }
            if settingType == 1 {
                NSUserDefaults.standardUserDefaults().setInteger(row, forKey:"count")
                tableView.reloadData()
            }
        default:break
        }
    }
}