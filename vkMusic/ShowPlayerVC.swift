//
//  ShowPlayerVC.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/12/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit



class ShowPlayerVC: UIViewController {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var currentPage: Int = 0
    private var previousPage: Int = 0
    var ticker: NSTimer?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ticker = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshState()
        playPauseButton.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
        ticker?.invalidate()
    }
    
    func refreshState(){
        switch AudioPlayer.sharedInstance.currentAudio {
        case .Some(let audio):
            self.titleLabel.text = audio.title
            self.artistLabel.text = audio.artist
            self.progressSlider.minimumValue = 0.0
            self.progressSlider.maximumValue = Float(AudioPlayer.sharedInstance.duration)
            
            switch AudioPlayer.sharedInstance.option {
            case .Continious:
                shuffleButton.tintColor = UIColor.blackColor()
                repeatButton.tintColor = UIColor.blackColor()
                
            case .Repeat:
                shuffleButton.tintColor = UIColor.blackColor()
                repeatButton.tintColor = UIColor.blueColor()
                
            case .Shuffle:
                shuffleButton.tintColor = UIColor.blueColor()
                repeatButton.tintColor = UIColor.blackColor()
            }
            
        default:
            return
        }
        
        refreshPlayPauseButton()
        refreshTimeLabels()
    }
    
    func refreshTimeLabels(){
        self.lastLabel.text = formatTimeInterval(NSTimeInterval(self.progressSlider.value))
        self.restLabel.text = formatTimeInterval(NSTimeInterval(self.progressSlider.maximumValue - self.progressSlider.value))
    }
    
    func tick(){
        self.progressSlider.setValue(Float(AudioPlayer.sharedInstance.currentTime), animated: true)
        refreshTimeLabels()
    }
    
    func formatTimeInterval(interval: NSTimeInterval) -> String {
        let seconds = Int(interval % 60.0)
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        
        let minutes = Int(interval / 60.0)
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        
        return "\(minutesString):\(secondsString)"
    }
    
    func refreshPlayPauseButton(){
        var playButtonImageName: String = ""
        switch AudioPlayer.sharedInstance.state {
        case .Play:
            playButtonImageName = "pause"
            
        case .Pause, .Stop:
            playButtonImageName = "play"
            
        }
        
        playPauseButton.setImage(UIImage(named: playButtonImageName), forState: UIControlState.Normal)
    }
    
    @IBAction func playPauseButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func progressSliderValueChanged(sender: AnyObject) {
        refreshTimeLabels()
        AudioPlayer.sharedInstance.seekToTime(Double(self.progressSlider.value))
    }
    
    @IBAction func repeatButtonTapped(sender: AnyObject) {
        switch AudioPlayer.sharedInstance.option {
        case .Continious:
            AudioPlayer.sharedInstance.option = .Repeat
            
        case .Shuffle:
            AudioPlayer.sharedInstance.option = .Repeat
            
        case .Repeat:
            AudioPlayer.sharedInstance.option = .Continious
        }
        
        refreshState()
    }
    
    @IBAction func shuffleButtonTapped(sender: AnyObject) {
        switch AudioPlayer.sharedInstance.option {
        case .Continious:
            AudioPlayer.sharedInstance.option = .Shuffle
            
        case .Shuffle:
            AudioPlayer.sharedInstance.option = .Continious
            
        case .Repeat:
            AudioPlayer.sharedInstance.option = .Shuffle
        }
        
        refreshState()
    }
    


    

}
