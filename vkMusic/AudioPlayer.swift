//
//  AudioPlayer.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/12/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation
import AVFoundation


class AudioPlayer: NSObject{
    
    enum PlaybackState {
        case Play
        case Pause
        case Stop
    }
    
    enum PlaybackOption {
        case Continious
        case Shuffle
        case Repeat
    }
    
    var state: PlaybackState = .Stop
    var option: PlaybackOption = .Continious
    
    private var player: AVQueuePlayer = AVQueuePlayer()
    var currentAudio: TrackList?{
        didSet{
            switch self.currentAudio {
            case .Some:
                
                let caURL = self.currentAudio!.url
                //let URL = caURL.scheme! + "://" + caURL.host! + caURL.path!
                //let nURL = NSURL(string: URL)
                var error: NSError?

                self.player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: caURL))
               
                switch error{
                case .Some:
                    println("Error while creating AVAudioPlayer with url \(self.currentAudio!.url): \(error!.localizedDescription)")
                    
                case .None:
                    println("none")
                    return
                }
            default:
                return
            }
        }
    }
    
    var duration : Double {
        get {
            switch self.player.currentItem {
            case .Some:
                return Double(CMTimeGetSeconds(self.player.currentItem.asset.duration))
                
            case .None:
                return 0
            }
        }
    }
    
    var currentTime : Double{
        get {
            switch self.player.currentItem {
            case .Some:
                return Double(CMTimeGetSeconds(self.player.currentItem.currentTime()))
                
            case .None:
                return 0
            }
        }
    }
    
    func seekToTime(time: Double){
        let targetTime = CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC))
        self.player.seekToTime(targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    
    class var sharedInstance : AudioPlayer {
        struct Static {
            static let instance : AudioPlayer = AudioPlayer()
        }
        return Static.instance
    }
    
    func play(){
        self.player.play()
        self.state = .Play
    }
    
    func pause(){
        self.player.pause()
        self.state = .Pause
    }
    
    func stop(){
        self.player.pause()
        self.state = .Stop
    }
    
    
}