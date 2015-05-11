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
    var url: String
    var lyrics_id: Int
    var genre: Int
    
    init (aid: Int, owner_id: Int, artist: String, title: String, duration: Int, url: String, lyrics_id: Int, genre: Int){
        self.aid = aid
        self.owner_id = owner_id
        self.artist = artist
        self.title = title
        self.duration = duration
        self.url = url
        self.lyrics_id = lyrics_id
        self.genre = genre
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
                
                var newTrack = TrackList(aid: aid, owner_id: owner_id, artist: artist, title: title, duration: duration, url: url, lyrics_id: lyrics_id, genre: genre)
                trackList.append(newTrack)
            }
            
        }
        
        return trackList
    }
    
}











