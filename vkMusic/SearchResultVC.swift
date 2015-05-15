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

class SearchResultVC: UIViewController {

    let kCellIdentifier: String = "SearchResultCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
   
    var timer: NSTimer? = nil
    var api : APIController?
    var imageCache = [String : UIImage]()
    var trackList = [TrackList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.tableView.separatorColor = UIColor.grayColor()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        GetTrackList("")
        
        self.tableView.addPullToRefresh({ [weak self] in
            self?.GetTrackList("")
            self?.tableView.stopPullToRefresh()
        })
    }
    
    func GetTrackList(searchText: String){
        let popular_songs = (NSUserDefaults.standardUserDefaults().boolForKey("popular_songs"))
        if popular_songs {
            api = APIController(delegate: self)
            api!.searchVKFor(searchText)
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
        
        if let popoverVC = self.storyboard?.instantiateViewControllerWithIdentifier("PlayMusic") as? PlayMusic
        {
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.trackList = self.trackList
            popoverVC.index = indexPath!.row
            
            AudioPlayer.sharedInstance.currentAudio = trackList[indexPath!.row]
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
    
    func showPopover(base: UIView, text: String)
    {
        if let popoverVC = self.storyboard?.instantiateViewControllerWithIdentifier("PlayMusic") as? PlayMusic
        {
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.trackList = self.trackList
            let popover = popoverVC.popoverPresentationController!
            popover.delegate = self
            var frame = UIScreen.mainScreen().applicationFrame
            popover.sourceView = view
            var rect = CGRectMake(0 , frame.origin.y / 2, frame.width, frame.height)
            popover.sourceRect = rect
            popover.permittedArrowDirections = UIPopoverArrowDirection.allZeros
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
}

extension SearchResultVC: APIControllerProtocol {
    
    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr = results["response"] as! NSArray
        //println(resultsArr)
        dispatch_async(dispatch_get_main_queue(), {
            self.trackList = TrackList.TrackListWithJSON(resultsArr)
            self.tableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
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

extension SearchResultVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! SearchResultCell
        
        let track = self.trackList[indexPath.row]
        cell.title.text = "\(track.artist) - \(track.title)"
        cell.duration.text = stringFromTimeInterval(track.duration)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentAudio = trackList[indexPath.row]
       
        var selectedCell = self.tableView.cellForRowAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
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
