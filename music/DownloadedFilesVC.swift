//
//  DownloadedFilesVC.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/17/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class DownloadedFilesVC: UIViewController, UIActionSheetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private var controlBar: PlayerControlBar?
    @IBOutlet private var volumeView: MPVolumeView?
    @IBOutlet private var blurAlbumArtworkImageView: UIImageView?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var downloadedFiles = [PlaylistItem]()
    var kCellIdentifier = "PlaylistTableViewCell"
    
    private var player: MusicPlayer?//PlaylistPlayer?
    
    var searcher = UISearchController()
    var searching = false
    var originalSectionData = [PlaylistItem]()
    var currentPlayList = [PlaylistItem]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blurAlbumArtworkImageView?.image = UIImage(named: "blue.jpg")
        player = MusicPlayer()
        player?.delegate = self
        controlBar?.player = player
  
        volumeView?.showsVolumeSlider = true
        volumeView?.showsRouteButton = false
        volumeView?.sizeToFit()
        self.getPlayList()
        
        self.tableView.separatorColor = UIColor.Colors.Grey.colorWithAlphaComponent(0.3)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.searchBar.sizeToFit()
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.addPullToRefresh({ [weak self] in
            self?.getPlayList()
            self?.tableView.stopPullToRefresh()
            })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        player?.pause()
    }
    
    //MARK: - events received from phone
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        player?.remoteControlReceivedWithEvent(event)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        //allow this instance to receive remote control events
        return true
    }
    
    func getPlayList(){
        player?.playlist.removeAll(keepCapacity: false)
        let items: [PlaylistItem] = getDownloadedAudioFiless() as! [PlaylistItem]
        self.originalSectionData = items
        self.currentPlayList = items
        player?.playlist.extend(items)
        self.tableView.reloadData()
    }
    
    func shufflePlaylist() {
        player?.shuffle()
        tableView?.reloadData()
    }
}

extension DownloadedFilesVC: MusicPlayerDelegate {
    func player(playlistPlayer: MusicPlayer, didChangeCurrentPlaylistItem playlistItem: PlaylistItem?) {
        if (playlistItem?.artwork != nil){
            blurAlbumArtworkImageView?.image = playlistItem?.artwork
        }
        if(playlistItem?.title != nil && playlistItem?.artist != nil){
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: playlistItem!.title! as String , MPMediaItemPropertyArtist: playlistItem!.artist! as String]
        }
        tableView?.reloadData()
    }
}

extension DownloadedFilesVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let player = self.player {
            return player.playlist.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell") as! PlaylistTableViewCell
        
        let item = player?.playlist[indexPath.row]
        
        if(player?.playlist[indexPath.row].artwork != nil){
            cell.albumArtworkImageView?.image = player?.playlist[indexPath.row].artwork
        }else{
            cell.albumArtworkImageView?.image = UIImage(named: "imgTrack")
        }
        
        cell.titleLabel?.text = item?.title
        if item?.artist != nil && item?.albumName != nil {
            cell.artistAndAlbumNameLabel?.text = "\(item!.artist!) | \(item!.albumName!)"
        }
        
        if player?.currentItem == item {
            cell.titleLabel?.textColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
            cell.artistAndAlbumNameLabel?.textColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        } else {
            cell.titleLabel?.textColor = UIColor.whiteColor()
            cell.artistAndAlbumNameLabel?.textColor = UIColor.whiteColor()
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        player?.setCurrentItemFromIndex(indexPath.row)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var deleteSongAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "delete", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            var filename: AnyObject? = self.player?.playlist[indexPath.row].asset!.valueForKey("URL")
            VFCacheHandler.sharedInstance.removeAudio(filename!.lastPathComponent)
            self.player?.playlist.removeAtIndex(indexPath.row)
    
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        })
        return [deleteSongAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
}

extension DownloadedFilesVC: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let target = searchText
        
        if target == "" {
            player?.playlist.removeAll(keepCapacity: false)
            player?.playlist.extend(self.originalSectionData)
            self.tableView.reloadData()
            return
        }
        self.currentPlayList = self.originalSectionData.filter({( file : PlaylistItem) -> Bool in
                var stringMatch = file.title!.rangeOfString(target, options:
                    NSStringCompareOptions.CaseInsensitiveSearch)
                return (stringMatch != nil)
        })
        player?.playlist.removeAll(keepCapacity: false)
        player?.playlist.extend(self.currentPlayList)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension DownloadedFilesVC: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}
