//
//  Timer.swift
//  DownloadManager
//
//  Created by Atakishiyev Orazdurdy on 5/9/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

class Timer: NSObject {
    
    internal var block, timerBlock: dispatch_block_t!
    internal var timer: dispatch_source_t?
    
    internal var fireDate: NSDate!
    internal var interval: Double = 1.0
    
    internal var repeats: Bool = false
    internal var pauseInBackground: Bool = false
    
    internal var didPauseInBackground = false
    
    init(interval: Double = 1.0, repeats: Bool = false, pauseInBackground: Bool = true, block: () -> ()) {
        super.init()
        
        self.block = block
        self.interval = interval
        self.repeats = repeats
        self.pauseInBackground = pauseInBackground
        
        self.start()
    }
    
    func start() {
        self.invalidate()
        
        
        self.timerBlock = { [weak self] in
            if let strongSelf = self {
                if (strongSelf.block != nil) {
                    strongSelf.block()
                }
                
                strongSelf.invalidate()
                
                if !strongSelf.repeats {
                    strongSelf.fireDate = nil
                } else {
                    strongSelf.start()
                }
            }
        }
        
        var start = dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(interval * Double(NSEC_PER_SEC))
        )
        
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        
        dispatch_source_set_timer(self.timer!, start, UInt64(interval * Double(NSEC_PER_SEC)), (1 * NSEC_PER_SEC) / 10)
        dispatch_source_set_event_handler(self.timer!, self.timerBlock)
        dispatch_resume(self.timer!)
        
        self.fireDate = NSDate().dateByAddingTimeInterval(interval)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resume", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pause", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    func resume() {
        if let date = self.fireDate {
            if NSDate().compare(self.fireDate) != .OrderedAscending {
                self.timerBlock()
                didPauseInBackground = false
                return
            } else if didPauseInBackground {
                didPauseInBackground = false
                
                let interval = self.fireDate.timeIntervalSinceDate(NSDate())
                
                var start = dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(interval * Double(NSEC_PER_SEC))
                )
                
                self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
                dispatch_source_set_timer(self.timer!, start, UInt64(interval * Double(NSEC_PER_SEC)), (1 * NSEC_PER_SEC) / 10)
                dispatch_source_set_event_handler(self.timer!, self.timerBlock)
                dispatch_resume(self.timer!)
            }
        }
    }
    
    func pause() {
        if self.pauseInBackground, let timer = self.timer {
            didPauseInBackground = true
            dispatch_source_cancel(timer)
            self.timer = nil
        }
    }
    
    func stop() {
        self.invalidate()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.invalidate()
    }
    
    func invalidate() {
        if let timer = self.timer {
            dispatch_source_cancel(timer)
            self.fireDate = nil
            self.timer    = nil
        }
    }
    
}