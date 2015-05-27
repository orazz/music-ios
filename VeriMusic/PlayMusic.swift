//
//  PlayMusic.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/13/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit

class PlayMusic: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var lbl_title: UILabel!
    
    var currentPage: Int = 0
    private var previousPage: Int = 0
    var ticker: NSTimer?
    var trackList = [TrackList]()
    var index = 0
    
    override var preferredContentSize: CGSize {
        get {
            if backView != nil && presentingViewController != nil {
                var height = presentingViewController!.view.bounds.size.height
                var size = CGSize(width: 200, height: height)
                return backView.sizeThatFits(presentingViewController!.view.bounds.size)
            }else
            {
                return super.preferredContentSize
            }
        }
        set {super.preferredContentSize = newValue}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ticker = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshState()
        refreshPlayPauseButton()
        ProgressView.shared.hideProgressView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        ticker?.invalidate()
    }
    
    @IBAction func progressSliderValueChanged(sender: AnyObject) {
        refreshTimeLabels()
        AudioPlayer.sharedInstance.seekToTime(Double(self.progressSlider.value))
    }
    
    func refreshState(){
        switch AudioPlayer.sharedInstance.currentAudio {
        case .Some(let audio):
            self.lbl_title.text = "\(audio.artist) - \(audio.title)"
            self.progressSlider.minimumValue = 0.0
            self.progressSlider.maximumValue = Float(AudioPlayer.sharedInstance.duration)
            
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
    
    func refreshPlayPauseButton(){
        var playButtonImageName: String = ""
        switch AudioPlayer.sharedInstance.state {
        case .Play:
            playButtonImageName = "ic_pause_asphalt.png"
            
        case .Pause, .Stop:
            playButtonImageName = "ic_play_asphalt.png"
            
        }
        
        playPauseButton.setImage(UIImage(named: playButtonImageName), forState: UIControlState.Normal)
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
    
    @IBAction func PlayeBtn(sender: AnyObject) {

        switch AudioPlayer.sharedInstance.state {
        case .Play:
            AudioPlayer.sharedInstance.pause()
            
        case .Pause, .Stop:
            AudioPlayer.sharedInstance.play()
        }
        refreshPlayPauseButton()
    }
}


