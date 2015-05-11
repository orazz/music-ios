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

class SearchResultVC: UIViewController, UITableViewDelegate, APIControllerProtocol{

    let kCellIdentifier: String = "SearchResultCell"
    var mediaPlayer: MPMoviePlayerController = MPMoviePlayerController()
    private var player: AVQueuePlayer = AVQueuePlayer()
    
    @IBOutlet var tableView : UITableView?
    var tableData = []
    //var api = APIController(delegate: self)
    var api : APIController?
    var imageCache = [String : UIImage]()
    var trackList = [TrackList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api = APIController(delegate: self)
        api!.searchVKFor("Jah Khalib", sort: "1", count: "300")
    }
    
    /// MARK: UITableViewDataSource, UITableViewDelegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! SearchResultCell
        
        let track = self.trackList[indexPath.row]
        cell.title.text = track.title
        cell.duration.text = "\(track.duration)"
        
        return cell
    }
    
    // The APIControllerProtocol method
    func didReceiveAPIResults(results: NSDictionary) {
        
        var resultsArr = results["response"] as! NSArray
        //println(resultsArr)
        dispatch_async(dispatch_get_main_queue(), {
            self.trackList = TrackList.TrackListWithJSON(resultsArr)
            self.tableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }

    
}

extension SearchResultVC: UITableViewDataSource {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var track = trackList[indexPath.row]
        println(track.url)
        self.player.pause()
        let nURL = NSURL(string: track.url)
        self.player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: nURL))
        self.player.play()
    }
}

