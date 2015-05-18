//
//  PlayMyMusic.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/17/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit

class PlayMyMusic: UIViewController {
    
    var musicPlayer:MusicPlayer = MusicPlayer()
    var audioFile: String?
    var audioFiles = [DownloadedFiles]()
    var currentSongIndex: Int?
    var totalSongsCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MusicPlayer.initSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*if let nonNilArtistAlbum = artistAlbum {
            let song = (nonNilArtistAlbum["songs"] as! NSArray).objectAtIndex(songIndex) as! NSDictionary
            self.musicPlayer.playSongWithId(song["songId"] as! NSNumber, title:song["title"] as! String, artist:nonNilArtistAlbum["artist"] as! String)
            
        }*/
        self.musicPlayer.playSong(audioFile!)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }

    //MARK: - user actions
    @IBAction func playPauseButtonTapped(sender: UIButton) {
        if (sender.titleLabel?.text == "Pause") {
            sender.setTitle("Play", forState: .Normal)
            musicPlayer.pause()
        } else {
            sender.setTitle("Pause", forState: .Normal)
            musicPlayer.play()
        }
    }
    
    @IBAction func nextTrack(sender: AnyObject) {
        self.musicPlayer.pause()
        self.musicPlayer.NextTrack(audioFiles[currentSongIndex! + 1].title)
    }
  
    //MARK: - events received from phone
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        musicPlayer.remoteControlReceivedWithEvent(event)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        //allow this instance to receive remote control events
        return true
    }
}
