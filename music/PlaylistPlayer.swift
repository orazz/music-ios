//
//  PlaylistPlayer.swift
//  music
//
//  Created by Atakishiyev Orazdurdy on 5/19/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit
import AVFoundation

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

protocol PlaylistPlayerDelegate {
    func player(playlistPlayer: PlaylistPlayer, didChangeCurrentPlaylistItem playlistItem: PlaylistItem?)
}

class PlaylistPlayer: NSObject {
    
    private let player = AVPlayer(playerItem: nil)
    
    var playlist: [PlaylistItem] = []
    var delegate: PlaylistPlayerDelegate?
    
    var currentItem: PlaylistItem? {
        return player.currentItem as? PlaylistItem
    }
    
    override init() {
        super.init()
        player.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playNextTrack:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    }
    
    func play() {
        if player.currentItem == nil {
            if let first = playlist.first {
                player.replaceCurrentItemWithPlayerItem(first)
                delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
            }
        }
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func paused() -> Bool {
        if player.currentItem != nil && player.rate != 0 {
            return false
        } else {
            return true
        }
    }
    
    func playNextTrack(notification: NSNotification) {
        self.nextTrack()
        player.play()
    }
    
    func nextTrack() {
        var next: PlaylistItem
        
        if let i = find(playlist, player.currentItem as! PlaylistItem) {
            next = playlist[mod(i + 1, playlist.count)]
        } else {
            next = playlist[0]
        }
        next.seekToTime(kCMTimeZero)
        
        let playing = player.rate > 0
        
        player.replaceCurrentItemWithPlayerItem(next)
        delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
        
        if playing {
            player.play()
        }
    }
    
    func previousTrack() {
        var previous: PlaylistItem
        
        if let i = find(playlist, player.currentItem as! PlaylistItem) {
            previous = playlist[mod(i - 1, playlist.count)]
        } else {
            previous = playlist[0]
        }
        previous.seekToTime(kCMTimeZero)
        
        let playing = player.rate > 0
        
        player.replaceCurrentItemWithPlayerItem(previous)
        delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
        
        if playing {
            player.play()
        }
    }
    
    func setCurrentItemFromIndex(index: Int) {
        let item = playlist[index]
        if item != currentItem {
            item.seekToTime(kCMTimeZero)
        }
        player.replaceCurrentItemWithPlayerItem(item)
        delegate?.player(self, didChangeCurrentPlaylistItem: self.currentItem)
    }
    
    func shuffle() {
        playlist.shuffle()
    }
}
