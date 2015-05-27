//
//  ViewController.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/9/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class SearchResultVC: UIViewController, DownloadManagerDelegate {

    let kCellIdentifier: String = "SearchResultCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsItem: UIBarButtonItem!
    @IBOutlet weak var playerItem: UIBarButtonItem!
   
    var timer: NSTimer? = nil
    var api : APIController?
    var imageCache = [String : UIImage]()
    var trackList = [TrackList]()
    var cacheFileSize: NSCache!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsItem.title = NSLocalizedString("settings", comment: "Settings")
        playerItem.title = NSLocalizedString("player", comment: "Player")
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.tableView.separatorColor = UIColor.Colors.Grey.colorWithAlphaComponent(0.3)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        GetTrackList("")
        
        self.tableView.addPullToRefresh({ [weak self] in
            self?.GetTrackList("")
            self?.tableView.stopPullToRefresh()
        })
        getDownloadedAudioFiles()
        DownloadManager.sharedInstance.subscribe(self)
        cacheFileSize = NSCache()
    }

    deinit {
        DownloadManager.sharedInstance.unsubscribe(self)
    }
    
    func GetTrackList(searchText: String){
        let popular_songs = (NSUserDefaults.standardUserDefaults().boolForKey("popular_songs"))

        if popular_songs {
            api = APIController(delegate: self)
            api!.searchVKFor(searchText)
        }else{
            if(searchText != ""){
                api = APIController(delegate: self)
                api!.searchVKFor(searchText)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPlayer" {
            if let blogActions = segue.destinationViewController as? PlayMusic {
                if let ppc = blogActions.popoverPresentationController {
                    ppc.delegate = self
                }
            }
        }
    }

    @IBAction func playBtnTapped(sender: UIButton) {
        
        let button = sender as UIButton
        let viewB = button.superview!
        let viewBack = viewB.superview
        let cell = viewBack?.superview as! SearchResultCell
        
        let indexPath = self.tableView.indexPathForCell(cell)
        
        showPopover(indexPath!)
    }
    
    func showPopover(indexPath: NSIndexPath)
    {
        if let popoverVC = self.storyboard?.instantiateViewControllerWithIdentifier("PlayMusic") as? PlayMusic
        {
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.trackList = self.trackList
            popoverVC.index = indexPath.row
            
            AudioPlayer.sharedInstance.currentAudio = trackList[indexPath.row]
            AudioPlayer.sharedInstance.play()
            ProgressView.shared.showProgressView(view)
            let popover = popoverVC.popoverPresentationController!
            popover.delegate = self
            var frame = UIScreen.mainScreen().applicationFrame
            popover.sourceView = view
            var rect = CGRectMake(0 , frame.origin.y , frame.width, frame.height)
            popover.sourceRect = rect
            popover.permittedArrowDirections = UIPopoverArrowDirection.allZeros
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
}

extension SearchResultVC: APIControllerProtocol {
    
    func didReceiveAPIResults(results: NSDictionary, indexPath: NSIndexPath) {
        if let resultsArr = results["response"] as? NSArray {
            //println(resultsArr)
            dispatch_async(dispatch_get_main_queue(), {
                self.trackList = TrackList.TrackListWithJSON(resultsArr)
                self.tableView!.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
        if let length = results["length"] as? String {
            println(length)
            dispatch_async(dispatch_get_main_queue(), {
            self.cacheFileSize.setObject("\((length as NSString).doubleValue/1024)", forKey: results["title"]!)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            })
        }
        if let status = results["status"] as? String {
            println(status)
        }
    }
    
    func result(status: String, error_msg: String, error_code: Int, captcha_sid: String, captcha_img: String)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if(error_code == 14){
            var captchaNeededVC = self.storyboard?.instantiateViewControllerWithIdentifier("CaptchaNeededVC") as! CaptchaNeededVC
            captchaNeededVC.captchaImgUrl = captcha_img
            captchaNeededVC.captcha_sid = captcha_sid
            self.navigationController?.presentViewController(captchaNeededVC, animated: true, completion: nil)
        }
        
        if(error_code == 6){
            self.GetTrackList("Fink")
        }
        
        if(error_code == 10){
            self.api?.getToken(Config.GET_TOKEN)
            GetTrackList("")
        }
        
    }
}

extension SearchResultVC: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        /*timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("getHints:"), userInfo: searchText, repeats: false)*/
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.GetTrackList(searchBar.text)
        self.searchBar.resignFirstResponder()
    }
    
    func getHints(timer: NSTimer) {
        if (timer.userInfo?.length >= 3){
            self.GetTrackList(timer.userInfo! as! String)
            self.searchBar.resignFirstResponder()
        }
    }

}

extension SearchResultVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! SearchResultCell
        
        let track = self.trackList[indexPath.row]
        cell.title.text = "\(track.artist) - \(track.title)"
        cell.durationBtn.titleLabel?.text = stringFromTimeInterval(track.duration)
        cell.progressView.hidden = true
        cell.size.hidden = true
        var selectedBack = UIView();
        selectedBack.backgroundColor = UIColor(hex: 0x9E9E9E, alpha: 0.1)
        cell.selectedBackgroundView = selectedBack

        if let size: String = cacheFileSize.objectForKey(track.title) as? String {
            cell.size.hidden = false
            cell.size.text = (NSString(format:"%.2f", (size as NSString).doubleValue/1024) as String) + " mb."
        }else{
            cell.size.text = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentAudio = trackList[indexPath.row]
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! SearchResultCell
        
        cell.selectedBackgroundView.backgroundColor = UIColor(hex: 0x9E9E9E, alpha: 0.1)
        cell.viewBackDuration.backgroundColor = UIColor.Colors.BlueGrey.colorWithAlphaComponent(0.7)
        dispatch_async(dispatch_get_main_queue(), {
            if(self.cacheFileSize.objectForKey(currentAudio.title) == nil) {
                self.api?.audioInfo(currentAudio, indexPath: indexPath)
            }
        })
        let shareMenu = UIAlertController(title: "\(currentAudio.artist)", message: "\(currentAudio.title)", preferredStyle: .ActionSheet)
        if let presentationController = shareMenu.popoverPresentationController {
            var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
            presentationController.sourceView = selectedCell?.contentView
            presentationController.sourceRect = selectedCell!.contentView.frame
        }
        
        let download = UIAlertAction(title: NSLocalizedString("download", comment: "Download"), style: .Default, handler: {
            (action:UIAlertAction!) -> Void in
            DownloadManager.sharedInstance.download(currentAudio, indexPath: indexPath)
        })
        let play = UIAlertAction(title: NSLocalizedString("play", comment: "Play button"), style: .Default, handler: {
            (action:UIAlertAction!) -> Void in
            self.showPopover(indexPath)
        })
        let share = UIAlertAction(title: NSLocalizedString("share", comment: "Share button"), style: .Default, handler: {
            (action:UIAlertAction!) -> Void in
            let textToShare = "Music"
            
            if let myWebsite = NSURL(string: "http://www.alashow.com/music")
            {
                let objectsToShare = [textToShare, myWebsite]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel button"), style: UIAlertActionStyle.Cancel, handler: nil)
        
        shareMenu.addAction(download)
        shareMenu.addAction(play)
        //shareMenu.addAction(share)
        shareMenu.addAction(cancelAction)

        self.presentViewController(shareMenu, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
}

extension SearchResultVC: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}

extension SearchResultVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        AudioPlayer.sharedInstance.pause()
    }
}

extension SearchResultVC: DownloadManagerDelegate {
    func downloadManager(downloadManager: DownloadManager, downloadDidFail url: NSURL, error: NSError, indexPath: NSIndexPath) {
        println("Failed to download: \(url.absoluteString)")
        var selectedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? SearchResultCell
        selectedCell?.progressView.hidden = true
    }
    
    func downloadManager(downloadManager: DownloadManager, downloadDidStart url: NSURL, resumed: Bool, indexPath: NSIndexPath) {
        println("Started to download: \(url.absoluteString)")
    }
    
    func downloadManager(downloadManager: DownloadManager, downloadDidFinish url: NSURL, indexPath: NSIndexPath) {
        println("Finished downloading: \(url.absoluteString)")
        var selectedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? SearchResultCell
        selectedCell?.progressView.hidden = true
    }
    
    func downloadManager(downloadManager: DownloadManager, downloadDidProgress url: NSURL, totalSize: UInt64, downloadedSize: UInt64, percentage: Double, averageDownloadSpeedInBytes: UInt64, timeRemaining: NSTimeInterval, indexPath: NSIndexPath) {
        //println("Downloading \(url.absoluteString) (Percentage: \(percentage))")
        var selectedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? SearchResultCell
        selectedCell?.progressView.hidden = false
        selectedCell?.counter = Int(percentage * 100)
    }
}
