//
//  DownloadManager.swift
//  DownloadManager
//
//  Created by Atakishiyev Orazdurdy on 5/9/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation

public protocol DownloadManagerDelegate: class {
    func downloadManager(downloadManager: DownloadManager, downloadDidFail url: NSURL, error: NSError, indexPath: NSIndexPath)
    func downloadManager(downloadManager: DownloadManager, downloadDidStart url: NSURL, resumed: Bool, indexPath: NSIndexPath)
    func downloadManager(downloadManager: DownloadManager, downloadDidFinish url: NSURL, indexPath: NSIndexPath)
    func downloadManager(downloadManager: DownloadManager, downloadDidProgress url: NSURL, totalSize: UInt64, downloadedSize: UInt64, percentage: Double, averageDownloadSpeedInBytes: UInt64, timeRemaining: NSTimeInterval, indexPath: NSIndexPath)
}

func ==(left: DownloadManager.Download, right: DownloadManager.Download) -> Bool {
    return left.url == right.url
}

public class DownloadManager: NSObject, NSURLConnectionDataDelegate {
    
    internal let queue = dispatch_queue_create("io.persson.DownloadManager", DISPATCH_QUEUE_CONCURRENT)
    
    internal var delegates: [DownloadManagerDelegate] = []
    internal var downloads: [DownloadManager.Download] = []
    
    
    
    class Download: Equatable {
        
        let url:      NSURL
        let filePath: String
        
        let stream:     NSOutputStream
        let connection: NSURLConnection
        
        var totalSize: UInt64
        var downloadedSize: UInt64 = 0
        
        var indexPath: NSIndexPath
        
        // Variables used for calculating average download speed
        // The lower the interval (downloadSampleInterval) the higher the accuracy (fluctuations)
        
        internal let sampleInterval       = 0.25
        internal let sampledSecondsNeeded = 5.0
        
        internal lazy var sampledBytesTotal: Int = {
            return Int(ceil(self.sampledSecondsNeeded / self.sampleInterval))
            }()
        
        internal var samples: [UInt64] = []
        internal var sampleTimer: Timer?
        internal var lastAverageCalculated = NSDate()
        
        internal var bytesWritten = 0
        internal let queue = dispatch_queue_create("dk.dr.radioapp.DownloadManager.SampleQueue", DISPATCH_QUEUE_CONCURRENT)
        
        var averageDownloadSpeed: UInt64 = UInt64.max
        
        init(url: NSURL, filePath: String, totalSize: UInt64, connection: NSURLConnection, indexPath: NSIndexPath) {
            dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
            
            self.url       = url
            self.filePath  = filePath
            self.totalSize = totalSize
            
            self.indexPath = indexPath
            
            if let dict: NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(self.filePath, error: nil) {
                self.downloadedSize = dict.fileSize()
            }
            
            self.stream     = NSOutputStream(toFileAtPath: self.filePath, append: self.downloadedSize > 0)!
            self.connection = connection
            
            self.stream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            self.stream.open()
            
            self.sampleTimer?.invalidate()
            self.sampleTimer = Timer(interval: self.sampleInterval, repeats: true, pauseInBackground: true, block: { [weak self] () -> () in
                if let strongSelf = self {
                    dispatch_sync(strongSelf.queue, { () -> Void in
                        strongSelf.samples.append(UInt64(strongSelf.bytesWritten))
                        
                        let diff = strongSelf.samples.count - strongSelf.sampledBytesTotal
                        
                        if diff > 0 {
                            for i in (0...diff - 1) {
                                strongSelf.samples.removeAtIndex(0)
                            }
                        }
                        
                        strongSelf.bytesWritten = 0
                        
                        let now = NSDate()
                        
                        if now.timeIntervalSinceDate(strongSelf.lastAverageCalculated) >= 5 && strongSelf.samples.count >= strongSelf.sampledBytesTotal {
                            var totalBytes: UInt64 = 0
                            
                            for sample in strongSelf.samples {
                                totalBytes += sample
                            }
                            
                            strongSelf.averageDownloadSpeed  = UInt64(round(Double(totalBytes) / strongSelf.sampledSecondsNeeded))
                            strongSelf.lastAverageCalculated = now
                        }
                    })
                }
                })
        }
        
        func write(data: NSData) {
            let written = self.stream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
            
            if written > 0 {
                dispatch_async(self.queue, { () -> Void in
                    self.bytesWritten += written
                })
            }
        }
        
        func close() {
            self.sampleTimer?.invalidate()
            self.sampleTimer = nil
            
            self.stream.close()
        }
        
    }
    
}

// MARK: Static vars

extension DownloadManager {
    
    public class var sharedInstance: DownloadManager {
        struct Singleton {
            static let instance = DownloadManager()
        }
        
        return Singleton.instance
    }
    
}

// MARK: Internal methods

extension DownloadManager {
    
    internal func downloadForConnection(connection: NSURLConnection) -> Download? {
        var result: Download? = nil
        
        sync {
            for download in self.downloads {
                if download.connection == connection {
                    result = download
                    break
                }
            }
        }
        
        return result
    }
    
    internal func sync(closure: () -> Void) {
        dispatch_sync(self.queue, closure)
    }
    
    internal func async(closure: () -> Void) {
        dispatch_async(self.queue, closure)
    }
    
}

// MARK: Public methods

extension DownloadManager {
    
    public func subscribe(delegate: DownloadManagerDelegate) {
        async {
            for (index, d) in enumerate(self.delegates) {
                if delegate === d {
                    return
                }
            }
            
            self.delegates.append(delegate)
        }
    }
    
    public func unsubscribe(delegate: DownloadManagerDelegate) {
        async {
            for (index, d) in enumerate(self.delegates) {
                if delegate === d {
                    self.delegates.removeAtIndex(index)
                    return
                }
            }
        }
    }
    
    public func isDownloading(url: NSURL) -> Bool {
        var result = false
        
        sync {
            for download in self.downloads {
                if download.url == url {
                    result = true
                    break
                }
            }
        }
        
        return result
    }
    
    public func download(url: NSURL, filePath: String, indexPath: NSIndexPath) -> Bool {
        if self.isDownloading(url) {
            return true
        }
    
        var request = NSMutableURLRequest(URL: url)
        
        if let dict: NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(filePath, error: nil) {
            request.addValue("bytes=\(dict.fileSize())-", forHTTPHeaderField: "Range")
        }
        
        if let connection = NSURLConnection(request: request, delegate: self, startImmediately: false) {
            sync {
                self.downloads.append(Download(url: url, filePath: filePath, totalSize: 0, connection: connection, indexPath: indexPath))
            }
            
            connection.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            connection.start()
            
            return true
        }
        
        return false
    }
    
    public func stopDownloading(url: NSURL) {
        sync {
            for download in self.downloads {
                if download.url == url {
                    download.connection.cancel()
                    download.close()
                    
                    self.downloads.remove(download)
                    
                    break
                }
            }
        }
    }
    
    func applicationWillTerminate() {
        sync {
            for download in self.downloads {
                download.connection.cancel()
                download.close()
            }
        }
    }
    
}

// MARK: Public methods

extension DownloadManager {
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if let download = self.downloadForConnection(connection) {
            let contentLength = response.expectedContentLength
            
            download.totalSize = contentLength == -1 ? 0 : UInt64(contentLength) + download.downloadedSize
            
            sync {
                for delegate in self.delegates {
                    delegate.downloadManager(self, downloadDidStart: download.url, resumed: download.totalSize > 0, indexPath: download.indexPath)
                }
            }
        }
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        if let download = self.downloadForConnection(connection) {
            var percentage: Double = 0
            var remaining: NSTimeInterval = NSTimeInterval.NaN
            
            sync {
                download.write(data)
                download.downloadedSize += UInt64(data.length)
                
                if download.totalSize > 0 {
                    percentage = Double(download.downloadedSize) / Double(download.totalSize)
                    
                    if download.averageDownloadSpeed != UInt64.max {
                        if download.averageDownloadSpeed == 0 {
                            remaining = NSTimeInterval.infinity
                        } else {
                            remaining = NSTimeInterval((download.totalSize - download.downloadedSize) / download.averageDownloadSpeed)
                        }
                    }
                }
                
                for delegate in self.delegates {
                    delegate.downloadManager(
                        self,
                        downloadDidProgress:         download.url,
                        totalSize:                   download.totalSize,
                        downloadedSize:              download.downloadedSize,
                        percentage:                  percentage,
                        averageDownloadSpeedInBytes: download.averageDownloadSpeed,
                        timeRemaining:               remaining,
                        indexPath:                   download.indexPath
                    )
                }
            }
        }
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        if let download = self.downloadForConnection(connection) {
            sync {
                for delegate in self.delegates {
                    delegate.downloadManager(self, downloadDidFail: download.url, error: error, indexPath: download.indexPath)
                }
                
                download.close()
                
                self.downloads.remove(download)
            }
        }
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        if let download = self.downloadForConnection(connection) {
            sync {
                for delegate in self.delegates {
                    delegate.downloadManager(self, downloadDidFinish: download.url, indexPath: download.indexPath)
                }
                
                download.close()
                
                self.downloads.remove(download)
            }
        }
    }
}
