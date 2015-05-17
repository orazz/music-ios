//
//  DownloadedFilesVC.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/17/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation
import UIKit

class DownloadedFilesCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var backViewDurationLbl: UIView!
    @IBOutlet weak var backViewPlayBtn: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Round(backViewPlayBtn)
        Round(backViewDurationLbl)
    }
    
    func Round(view: UIView){
        view.layer.cornerRadius = 10.0
        view.layer.borderColor = UIColor.grayColor().CGColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
    }
}

class DownloadedFilesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var downloadedFiles = [DownloadedFiles]()
    var kCellIdentifier = "DownloadedFilesCell"
    
    var searcher = UISearchController()
    var searching = false
    var originalSectionData = [DownloadedFiles]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadedFiles = DownloadedFiles.DownloadedFilesWithArray(getDownloadedAudioFiles())
        self.tableView.reloadData()
        self.tableView.separatorColor = UIColor.Colors.Grey.colorWithAlphaComponent(0.3)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.SearchSettings()
    }
    
    func SearchSettings(){
        if self.downloadedFiles.count > 0 {
            self.originalSectionData = self.downloadedFiles
            let searcher = UISearchController(searchResultsController:nil)
            self.searcher = searcher
            searcher.dimsBackgroundDuringPresentation = false
            searcher.searchResultsUpdater = self
            searcher.delegate = self
            //searcher.searchBar.searchBarStyle = UISearchBarStyle.Minimal
            let b = searcher.searchBar
            b.sizeToFit() // crucial, trust me on this one
            b.autocapitalizationType = .None
            self.tableView.tableHeaderView = b
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
    }
}

extension DownloadedFilesVC: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedFiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! DownloadedFilesCell
        
        if self.downloadedFiles.count > 0 {
            let audioFile = self.downloadedFiles[indexPath.row]
            cell.lblTitle.text = audioFile.title
            cell.lblDuration.text = audioFile.duration
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
}

extension DownloadedFilesVC : UISearchControllerDelegate {
    // flag for whoever needs it (in this case, sectionIndexTitles...)
    func willPresentSearchController(searchController: UISearchController) {
        self.searching = true
    }
    func willDismissSearchController(searchController: UISearchController) {
        self.searching = false
    }
}

extension DownloadedFilesVC : UISearchResultsUpdating {

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let sb = searchController.searchBar
        let target = sb.text
        if target == "" {
            self.downloadedFiles = self.originalSectionData
            self.tableView.reloadData()
            return
        }
        self.downloadedFiles = self.originalSectionData.filter({( file : DownloadedFiles) -> Bool in
            var stringMatch = file.title.rangeOfString(target, options:
                NSStringCompareOptions.CaseInsensitiveSearch)
            return (stringMatch != nil)
        })
        
        self.tableView.reloadData()
    }
}

