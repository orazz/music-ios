//
//  CacheHandler.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/12/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation
import UIKit

public protocol VFCacheHandlerDelegate: class {
    func downloadManager(result: String)
}

public class VFCacheHandler : NSObject, NSURLSessionDownloadDelegate {
    
    private var backgroundSession: NSURLSession?
    private var dictionary = Dictionary<NSURL, NSURL>()
    
    internal var delegates: [VFCacheHandlerDelegate] = []
    
    override init() {
        super.init()
        backgroundSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    public class var sharedInstance: VFCacheHandler {
        struct Singleton {
            static let instance = VFCacheHandler()
        }
        
        return Singleton.instance
    }
   /* class var sharedInstance : VFCacheHandler {
        struct Static {
            static let instance : VFCacheHandler = VFCacheHandler()
        }
        
        return Static.instance
    }*/
    
    func downloadAudio(audio: TrackList){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self,
            delegateQueue: nil)
        let downloadTask = session.downloadTaskWithURL(audio.url, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            switch (location, error){
            case (.Some, .None):
                var filename = "\(audio.artist) - \(audio.title).mp3"
                switch self.saveTemporaryAudioFromLocation(location, filename: filename) {
                case .Some(let newLocation):
                    println("New file location \(newLocation)")
                    self.sync {
                        for delegate in self.delegates {
                            delegate.downloadManager("--------------------\n")
                        }
                    }
                    self.dictionary[audio.url] = newLocation
                case .None:
                    return
                }
                
            case (.None, .None):
                println("Empty location")
                
            case (.None, .Some):
                println("Error \(error.description)")
                
            default:
                return
            }
        })
        
        downloadTask.resume()
    }
    /*
    func removeAudio(audio: TrackList){
        switch localURLForAudio(audio){
        case .Some(let localURL):
            var error: NSError?
            if !NSFileManager.defaultManager().removeItemAtURL(localURL, error: &error) {
                println("Error while removing audio from cache: \(error?.localizedDescription)")
            } else {
                self.dictionary.removeValueForKey(audio.remoteURL)
            }
            
        default:
            return
        }
    }*/
    
    func removeAudio(audioFilename: String){
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let audioPath = documentsPath.stringByAppendingPathComponent("Audio")
        let audioFileURL = NSURL(fileURLWithPath:audioPath.stringByAppendingPathComponent(audioFilename))
        var error: NSError?
        if !NSFileManager.defaultManager().removeItemAtURL(audioFileURL!, error: &error) {
            println("Error while removing audio from cache: \(error?.localizedDescription)")
        } 
    }
    
    func localURLForAudio(audio: TrackList) -> NSURL?{
        return self.dictionary[audio.remoteUrl]
    }
    
    //MARK: - NSURLSession Delegate methods
    
    public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?){
        
    }
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void){
        completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil)
    }
    
    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession){
        
    }
    
    func saveTemporaryAudioFromLocation(location: NSURL, filename: String) -> NSURL?{
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let audioPath = documentsPath.stringByAppendingPathComponent("Audio")
        let audioFileURL = NSURL(fileURLWithPath:audioPath.stringByAppendingPathComponent(filename))
        
        var error: NSError?
        
        if !NSFileManager.defaultManager().createDirectoryAtPath(audioPath, withIntermediateDirectories: true, attributes: nil, error: &error) {
            println("Error while Audio folder creation: \(error?.localizedDescription)")
            return nil
        }
        
        
        if NSFileManager.defaultManager().fileExistsAtPath(audioFileURL!.path!) {
            println("File already exists!")
            return audioFileURL
        }
        
        if NSFileManager.defaultManager().copyItemAtURL(location, toURL: audioFileURL!, error: &error) {
            return audioFileURL
        } else {
            println("Error while temp audio file replacing: \(error?.localizedDescription)")
            return nil
        }
    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
    }
    
    /* Sent periodically to notify the delegate of download progress. */
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
    }
    
    /* Sent when a download has been resumed. If a download failed with an
    * error, the -userInfo dictionary of the error will contain an
    * NSURLSessionDownloadTaskResumeData key, whose value is the resume
    * data.
    */
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        
    }
    internal let queue = dispatch_queue_create("io.persson.DownloadManager", DISPATCH_QUEUE_CONCURRENT)
    
    internal func sync(closure: () -> Void) {
        dispatch_sync(self.queue, closure)
    }
    
    internal func async(closure: () -> Void) {
        dispatch_async(self.queue, closure)
    }

}
extension VFCacheHandler {
    
    public func subscribe(delegate: VFCacheHandlerDelegate) {
        async {
            for (index, d) in enumerate(self.delegates) {
                if delegate === d {
                    return
                }
            }
            
            self.delegates.append(delegate)
        }
    }
    
    public func unsubscribe(delegate: VFCacheHandlerDelegate) {
        async {
            for (index, d) in enumerate(self.delegates) {
                if delegate === d {
                    self.delegates.removeAtIndex(index)
                    return
                }
            }
        }
}
}
