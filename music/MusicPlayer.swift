//
//  MusicPlayer.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/17/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit

import AVFoundation
import MediaPlayer

private func mod(n: Int, m: Int) -> Int {
    assert(m > 0, "m must be positive")
    return n >= 0 ? n % m : m - (-n) % m
}

private extension Array {
    mutating func shuffle() {
        if self.count > 0 {
            for i in 0..<(count - 1) {
                let j = Int(arc4random_uniform(UInt32(count - i))) + i
                swap(&self[i], &self[j])
            }
        }
    }
}

protocol MusicPlayerDelegate {
    func player(playlistPlayer: MusicPlayer, didChangeCurrentPlaylistItem playlistItem: PlaylistItem?)
}

class MusicPlayer: NSObject {
    
    let avQueuePlayer:AVQueuePlayer = AVQueuePlayer()
    
    var playlist: [PlaylistItem] = []
    var delegate: MusicPlayerDelegate?
    
    var currentItem: PlaylistItem? {
        return avQueuePlayer.currentItem as? PlaylistItem
    }
    
    override init() {
        super.init()
        avQueuePlayer.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playNextTrack:", name: AVPlayerItemDidPlayToEndTimeNotification, object: avQueuePlayer.currentItem)
    }
    
    /**
    Initialises the audio session
    */
    class func initSession() {
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: AVAudioSessionInterruptionNotification, object: AVAudioSession.sharedInstance())
        var error:NSError?
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &error)
        
        if let nonNilError = error {
            println("an error occurred when audio session category.\n \(error)")
        }
        
        var activationError:NSError?
        let success = AVAudioSession.sharedInstance().setActive(true, error: &activationError)
        if !success {
            if let nonNilActivationError = activationError {
                println("an error occurred when audio session category.\n \(nonNilActivationError)")
            } else {
                println("audio session could not be activated")
            }
        }
    }
    
    func play() {
        if avQueuePlayer.currentItem == nil {
            if let first = playlist.first {
                avQueuePlayer.replaceCurrentItemWithPlayerItem(first)
                delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
            }
        }
        avQueuePlayer.play()
    }
    
    func pause() {
        avQueuePlayer.pause()
    }
    
    func paused() -> Bool {
        if avQueuePlayer.currentItem != nil && avQueuePlayer.rate != 0 {
            return false
        } else {
            return true
        }
    }
    
    func playNextTrack(notification: NSNotification) {
        println("dd")
        var repeat: Bool = false
        if let bool = NSUserDefaults.standardUserDefaults().valueForKey("repeat") as? Bool {
            repeat = bool
        }
        
        if(repeat){
            seekToTime()
        }else{
            self.nextTrack()
        }
    }
    
    func seekToTime(){
        let targetTime = CMTimeMakeWithSeconds(0.0, Int32(NSEC_PER_SEC))
        self.avQueuePlayer.seekToTime(targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func nextTrack() {
        var next: PlaylistItem
        
        if let i = find(playlist, avQueuePlayer.currentItem as! PlaylistItem) {
            next = playlist[mod(i + 1, playlist.count)]
        } else {
            next = playlist[0]
        }
        next.seekToTime(kCMTimeZero)
        
        let playing = avQueuePlayer.rate > 0
        
        avQueuePlayer.replaceCurrentItemWithPlayerItem(next)
        delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
        
        if playing {
            avQueuePlayer.play()
        }
    }
    
    func previousTrack() {
        var previous: PlaylistItem
        
        if let i = find(playlist, avQueuePlayer.currentItem as! PlaylistItem) {
            previous = playlist[mod(i - 1, playlist.count)]
        } else {
            previous = playlist[0]
        }
        previous.seekToTime(kCMTimeZero)
        
        let playing = avQueuePlayer.rate > 0
        
        avQueuePlayer.replaceCurrentItemWithPlayerItem(previous)
        delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
        
        if playing {
            avQueuePlayer.play()
        }
    }
    
    func setCurrentItemFromIndex(index: Int) {
        let item = playlist[index]
        if item != currentItem {
            item.seekToTime(kCMTimeZero)
        }
        avQueuePlayer.replaceCurrentItemWithPlayerItem(item)
        delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
    }
    
    func shuffle() {
        playlist.shuffle()
    }

    func remoteControlReceivedWithEvent(receivedEvent:UIEvent)  {
        if (receivedEvent.type == .RemoteControl) {
            switch receivedEvent.subtype {
            case .RemoteControlTogglePlayPause:
                if avQueuePlayer.rate > 0.0 {
                    avQueuePlayer.pause()
                } else {
                    avQueuePlayer.play()
                }
            case .RemoteControlPlay:
                avQueuePlayer.play()
            case .RemoteControlPause:
                avQueuePlayer.pause()
            case .RemoteControlNextTrack:
                self.nextTrack()
                avQueuePlayer.play()
            case .RemoteControlPreviousTrack:
                self.previousTrack()
                avQueuePlayer.play()
            default:
                println("received sub type \(receivedEvent.subtype) Ignoring")
            }
        }
    }
    
    //MARK: - Notifications
    func audioSessionInterrupted(notification:NSNotification)
    {
        println("interruption received: \(notification)")
    }
    
    //response to remote control events
    
    
    
    
    
}