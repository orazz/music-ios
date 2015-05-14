//
//  TrackList.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/9/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation

class TrackList {
    
    var aid: Int
    var owner_id: Int
    var artist: String
    var title: String
    var duration: Int
    var lyrics_id: Int
    var genre: Int
    var remoteUrl: NSURL
    
    init (aid: Int, owner_id: Int, artist: String, title: String, duration: Int, url: String, lyrics_id: Int, genre: Int, remoteUrl: NSURL){
        self.aid = aid
        self.owner_id = owner_id
        self.artist = artist
        self.title = title
        self.duration = duration
        self.lyrics_id = lyrics_id
        self.genre = genre
        self.remoteUrl = remoteUrl
    }
    
    var url: NSURL {
        get{
            switch VFCacheHandler.sharedInstance.localURLForAudio(self) {
            case .Some:
                return VFCacheHandler.sharedInstance.localURLForAudio(self)!
                
            case .None:
                return self.remoteUrl
            }
        }
    }
    
    class func TrackListWithJSON(trackListResult: NSArray) -> [TrackList] {
        
        var trackList = [TrackList]()
       
        if trackListResult.count > 0 {
            for var index = 1; index < trackListResult.count; index++ {
                let aid = trackListResult[index]["aid"] as! Int
                let owner_id = trackListResult[index]["owner_id"] as! Int
                let artist = trackListResult[index]["artist"] as? String ?? ""
                let title = trackListResult[index]["title"] as? String ?? "untitled"
                let duration = trackListResult[index]["duration"] as! Int
                let url = trackListResult[index]["url"] as! String
                let lyrics_id = trackListResult[index]["lyrics_id"] as? Int ?? 0
                let genre = trackListResult[index]["genre"] as? Int ?? 0
                let urlString = trackListResult[index]["url"] as! String
                let remoteURL = NSURL(string: urlString)!
                
                var newTrack = TrackList(aid: aid, owner_id: owner_id, artist: artist, title: title, duration: duration, url: url, lyrics_id: lyrics_id, genre: genre, remoteUrl: remoteURL)
                trackList.append(newTrack)
            }
            
        }
        
        return trackList
    }
    
}











