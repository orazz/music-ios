//
//  PlaylistItem.swift
//  music
//
//  Created by Atakishiyev Orazdurdy on 5/19/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

private var playlistItemImageCache: [String: UIImage] = [:]

extension MPMediaItem {
    
    func asPlaylistItem() -> PlaylistItem {
        let item = PlaylistItem(URL: self.assetURL)
        println(item)
        item.title = self.title
        item.artist = self.artist
        item.albumName = self.albumTitle
        
        var audioAsset = AVURLAsset(URL: NSURL(string: self.assetURL.path!), options: nil)
        var audioDuration = audioAsset.duration;
        var audioDurationSeconds = Int(CMTimeGetSeconds(audioDuration))
        
        item.durationOfFile = stringFromTimeInterval(audioDurationSeconds)
        
        let cacheID = "\(item.artist!) | \(item.albumName!)"
        let kAlbumArtworkSize = CGSizeMake(256.0, 256.0)
        if let cached = playlistItemImageCache[cacheID] {
            item.artwork = cached
        } else if let artwork = self.artwork?.imageWithSize(kAlbumArtworkSize) {
            playlistItemImageCache[cacheID] = artwork
            item.artwork = artwork
        }
        
        return item
    }
}

class PlaylistItem: AVPlayerItem {
    
    class func clearImageCache() {
        playlistItemImageCache.removeAll(keepCapacity: false)
    }
    
    var durationOfFile: String = ""
    
    lazy var title: String? = {
        if let titleMetadataItem = AVMetadataItem.metadataItemsFromArray(self.asset.commonMetadata, withKey: AVMetadataCommonKeyTitle, keySpace: AVMetadataKeySpaceCommon).first as? AVMetadataItem {
            return titleMetadataItem.value as? String
        }
        return nil
        }()
    
    lazy var artist: String? = {
        if let artistMetadataItem = AVMetadataItem.metadataItemsFromArray(self.asset.commonMetadata, withKey: AVMetadataCommonKeyArtist, keySpace: AVMetadataKeySpaceCommon).first as? AVMetadataItem {
            return artistMetadataItem.value as? String
        }
        return nil
        }()
    
    lazy var albumName: String? = {
        if let albumNameMetadataItem = AVMetadataItem.metadataItemsFromArray(self.asset.commonMetadata, withKey: AVMetadataCommonKeyAlbumName, keySpace: AVMetadataKeySpaceCommon).first as? AVMetadataItem {
            return albumNameMetadataItem.value as? String
        }
        return nil
        }()
    
    lazy var artwork: UIImage? = {
        
        var cacheID: String = ""
        if self.artist != nil && self.albumName != nil {
            cacheID = "\(self.artist) | \(self.albumName)"
        }
        
        if let cached = playlistItemImageCache[cacheID] {
            return cached
        } else if let artworkMetadataItem = AVMetadataItem.metadataItemsFromArray(self.asset.commonMetadata, withKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon).first as? AVMetadataItem {
            
            if let artworkMetadataDictionary = artworkMetadataItem.value as? [String: AnyObject] {
                if let artworkData = artworkMetadataDictionary["data"] as? NSData {
                    if let image = UIImage(data: artworkData) {
                        playlistItemImageCache[cacheID] = image
                        return image
                    }
                }
            } else if let artworkData = artworkMetadataItem.value as? NSData {
                if let image = UIImage(data: artworkData) {
                    playlistItemImageCache[cacheID] = image
                    return image
                }
            }
            
        }
        return nil
        }()
}
