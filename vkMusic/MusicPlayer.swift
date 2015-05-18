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
class MusicPlayer: NSObject {
    
    let avQueuePlayer:AVQueuePlayer = AVQueuePlayer()
    
    /**
    Initialises the audio session
    */
    class func initSession() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: AVAudioSessionInterruptionNotification, object: AVAudioSession.sharedInstance())
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
    
    /**
    Pause music
    */
    func pause() {
        avQueuePlayer.pause()
    }
    
    /**
    Play music
    */
    func play() {
        avQueuePlayer.play()
    }
    
    func playSongWithId(songId:NSNumber, title:String, artist:String) {
       /* MusicQuery().queryForSongWithId(songId, completionHandler: {[weak self] (result:MPMediaItem?) -> Void in
            if let nonNilResult = result {
                let assetUrl:NSURL = nonNilResult.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
                let avSongItem = AVPlayerItem(URL: assetUrl)
                self!.avQueuePlayer.insertItem(avSongItem, afterItem: nil)
                self!.play()
                //display now playing info on control center
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: title, MPMediaItemPropertyArtist: artist]
            }
            })*/
        
    }
    
    func playSong(audioFile:String){
        var documentsPathh = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let audioPathh = documentsPathh.stringByAppendingPathComponent("Audio")
        let audioFileURL = NSURL(fileURLWithPath:audioPathh.stringByAppendingPathComponent(audioFile))
        
        var audioAsset = AVURLAsset(URL: audioFileURL, options: nil)
        
        let avSongItem = AVPlayerItem(URL: audioFileURL)
        self.avQueuePlayer.insertItem(avSongItem, afterItem: nil)
        self.play()
        //display now playing info on control center
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: audioFile, MPMediaItemPropertyArtist: "Music"]
    }
    
    func NextTrack(audioFile:String){
        var documentsPathh = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let audioPathh = documentsPathh.stringByAppendingPathComponent("Audio")
        let audioFileURL = NSURL(fileURLWithPath:audioPathh.stringByAppendingPathComponent(audioFile))
        
        var audioAsset = AVURLAsset(URL: audioFileURL, options: nil)
        
        let avSongItem = AVPlayerItem(URL: audioFileURL)
        self.avQueuePlayer.replaceCurrentItemWithPlayerItem(avSongItem)
        self.play()
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: audioFile, MPMediaItemPropertyArtist: "Music"]
    }
    
    //MARK: - Notifications
    func audioSessionInterrupted(notification:NSNotification)
    {
        println("interruption received: \(notification)")
    }
    
    //response to remote control events
    
    func remoteControlReceivedWithEvent(receivedEvent:UIEvent)  {
        if (receivedEvent.type == .RemoteControl) {
            switch receivedEvent.subtype {
            case .RemoteControlTogglePlayPause:
                if avQueuePlayer.rate > 0.0 {
                    pause()
                } else {
                    play()
                }
            case .RemoteControlPlay:
                play()
            case .RemoteControlPause:
                pause()
            case .RemoteControlNextTrack:
                println("next")
            case .RemoteControlPreviousTrack:
                println("previous")
            default:
                println("received sub type \(receivedEvent.subtype) Ignoring")
            }
        }
    }
    
    
    
}