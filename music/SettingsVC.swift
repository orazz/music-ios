//
//  Settings.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/15/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sectionNames = ["Gözleg", "Sany", "Diňe aýdymçyny", "Meşhur aýdymlar", "Version"]
    var sectionData = [["Sortirowka"],["Her gözlegde iň kän jogap berilmeli aýdymalryň sany"], ["Gözlegde diňe aýdymçynyň ady boýunça gözle"],["Programma açylanda meşhur aýdymalry görkez"],["music-ios v1.0.0(1)"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "settingsList"){
            
        }
    }
    
    @IBAction func switchChanged(sender: AnyObject) {

        var sw = sender as! UISwitch
        var view = sw.superview
        let cell = view?.superview as! SettingsCellWithSwitch
        
        let indexPath = self.tableView.indexPathForCell(cell)
        if indexPath!.section == 2{
            NSUserDefaults.standardUserDefaults().setBool(sw.on, forKey: "performer_only")
        }
        if indexPath!.section == 3{
            NSUserDefaults.standardUserDefaults().setBool(sw.on, forKey: "popular_songs")
        }
    }
    
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionData[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var section = indexPath.section
        
        if(section == 0 || section == 1)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SettingsCell
            let s = self.sectionData[indexPath.section][indexPath.row]
            cell.title.text = "\(s)"
            return cell
        }
        else if(section == 2 || section == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("CellWithSwitch", forIndexPath: indexPath) as! SettingsCellWithSwitch
            let s = self.sectionData[indexPath.section][indexPath.row]
            cell.title.text = s
            if section == 2 {
                let switchBtn = NSUserDefaults.standardUserDefaults().boolForKey("performer_only")
                cell.switchBtn.on = switchBtn
            }
            if section == 3 {
                let switchBtn = NSUserDefaults.standardUserDefaults().boolForKey("popular_songs")
                cell.switchBtn.on = switchBtn
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellUnSegue", forIndexPath: indexPath) as! SettingsCellUnSegue
            let s = self.sectionData[indexPath.section][indexPath.row]
            cell.title.text = s
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.sectionNames[section].isEmpty {
            return self.sectionNames[section] as String
        }
        return ""
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0 :
            var settingsSort = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsList") as! SettingsSort
            settingsSort.settingType = indexPath.section
            self.navigationController?.pushViewController(settingsSort, animated: true)
        case 1:
            var settingsSort = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsList") as! SettingsSort
            settingsSort.settingType = indexPath.section
            self.navigationController?.pushViewController(settingsSort, animated: true)
        default: break
        }
    }

}

class SettingsCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

class SettingsCellWithSwitch: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
}

class SettingsCellUnSegue: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

