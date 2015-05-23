//
//  APIController.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/9/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

struct Config {
    
    static let VK_SERVER = "https://api.vk.com/"
    static let VK_AUDIO_SEARCH = VK_SERVER + "method/audio.search"
    static let ACCESS_TOKEN =  "3e2f0b5c127bc8bccc5e4b20eeb55117c0c09079c9e6a4788735f9c9615ccf628cc7f1919bf0acb329c2b"
}

func stringFromTimeInterval(interval: Int) -> String{
    var ti = NSInteger(interval)
    var seconds: NSInteger = ti % 60
    var minutes: NSInteger = (ti / 60) % 60
    var hours: NSInteger = (ti/3600)
    if hours > 0 {
        return NSString(format: "%02ld:%02ld:%02ld", hours, minutes, seconds) as String
    }
    return NSString(format: "%02ld:%02ld", minutes, seconds) as String
}

func getCountMusic(count: Int) -> Int{
    switch(count){
        case 0:
        return 30
        case 1: return 50
        case 2: return 100
        case 3: return 200
        case 4: return 300
        default: break
    }
    return 10
}

func getAudioFileDurationFromName(filename: String) -> String {
    var documentsPathh = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    let audioPathh = documentsPathh.stringByAppendingPathComponent("Audio")
    let audioFileURL = NSURL(fileURLWithPath:audioPathh.stringByAppendingPathComponent(filename))
    
    var audioAsset = AVURLAsset(URL: audioFileURL, options: nil)
    var audioDuration = audioAsset.duration;
    var audioDurationSeconds = Int(CMTimeGetSeconds(audioDuration))
    
    return "\(stringFromTimeInterval(audioDurationSeconds))"
}

func getDownloadedAudioFiles() -> NSArray {
    
    let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
    
    if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
        let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
        
        var mp3FilesAVURL = [PlaylistItem]()
        
        for mp3 in mp3Files {
            mp3FilesAVURL.append(getAudioAsseUrlForFilename(mp3))
        }
        
        return mp3FilesAVURL
    }
    
    return []
}

func getAudioAsseUrlForFilename(audioFile: String) -> PlaylistItem {
    var documentsPathh = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    let audioFileURL = NSURL(fileURLWithPath:documentsPathh.stringByAppendingPathComponent(audioFile))
    
    var audioAsset = PlaylistItem(URL: audioFileURL)
    
    return audioAsset
}

@objc
protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary, indexPath: NSIndexPath)
    optional func result(status: String, error_msg: String, error_code: Int, captcha_sid: String, captcha_img: String)
}

class APIController {
    
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func clientRequest(path: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if let json = self.CheckResponse(data){
                self.delegate.didReceiveAPIResults(json, indexPath: NSIndexPath())
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func CheckResponse(responseObject: AnyObject) -> NSDictionary? {
        var err: NSError?
        if let data = responseObject as? NSData {
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary {
                //println(json)
                if (json.objectForKey("response") as? NSArray != nil){
                    return json
                }
                else if let error = json.objectForKey("error") as? NSDictionary {
                    
                    if let error_code = error["error_code"] as? Int {
                        if let error_msg = error.objectForKey("error_msg") as? String {
                            println("\(error_code)  \(error_msg)")

                            switch error_code {
                                case 14:
                                    let captcha_sid = error["captcha_sid"] as? String
                                    let captcha_img = error["captcha_img"] as? String
                                    self.delegate.result!("error", error_msg: error_msg, error_code: error_code, captcha_sid: captcha_sid!, captcha_img: captcha_img!)
                                    println("\(captcha_sid!)  \(captcha_img!)")
                                case 6:
                                    self.delegate.result!("error", error_msg: error_msg, error_code: error_code, captcha_sid: "", captcha_img: "")
                                case 10:
                                    self.delegate.result!("error", error_msg: error_msg, error_code: error_code, captcha_sid: "", captcha_img: "")
                                default:break
                            }
                        }
                    }
                    
                } else {
                    println("Check response return error:\n \(json) \n \(err)")
                }
            }
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        return nil
    }
    
    func searchVKFor(searchTerm: String) {
        
        let VKSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        if let escapedSearchTerm = VKSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            
            let sort = NSUserDefaults.standardUserDefaults().integerForKey("sort")
            let count = getCountMusic(NSUserDefaults.standardUserDefaults().integerForKey("count"))
            let performer_only_bool = NSUserDefaults.standardUserDefaults().boolForKey("performer_only") ? 1 : 0
            
            var urlPath = "\(Config.VK_AUDIO_SEARCH)?access_token=\(Config.ACCESS_TOKEN)&q=\(escapedSearchTerm)&sort=\(sort)&count=\(count)&performer_only=\(performer_only_bool)"

            clientRequest(urlPath)
        }
    }
    
    func audioInfo(audio: TrackList, indexPath: NSIndexPath){
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(audio.url, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                //println(httpResponse)
                if let contentType = httpResponse.allHeaderFields["Content-Length"] as? String {
                    //println(contentType)
                    self.delegate.didReceiveAPIResults(["length": contentType, "title": audio.title], indexPath: indexPath)
                }
            }
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func captchaWrite(captcha_sid: String, captcha_key: String){
        let url = "\(Config.VK_AUDIO_SEARCH)?access_token=\(Config.ACCESS_TOKEN)&captcha_sid=\(captcha_sid)&captcha_key=\(captcha_key)"
        clientRequest(url)
    }
    
}