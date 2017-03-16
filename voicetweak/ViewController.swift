//
//  ViewController.swift
//  VoiceTweak
//
//  Created by Pedro Pachuca on 4/7/16.
//  Copyright © 2016 Pedro Pachuca. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var rate : Float = 1.0
    var audioURL : URL?
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var loopSwitch: UISwitch!
    @IBOutlet weak var playButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpAudioRecorder()
    }
    
    func setUpAudioRecorder() {
        do {
            let basePath : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
            let pathComponenets = [basePath, "theAudio.m4a"]
            self.audioURL = URL.init(fileURLWithPath: pathComponenets[0] + "/" + pathComponenets[1]);
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try session.setActive(true)
            
            var recordSettings = [String : AnyObject]()
            recordSettings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            recordSettings[AVSampleRateKey] = 44100.0 as AnyObject?
            recordSettings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            self.audioRecorder = try AVAudioRecorder(url: self.audioURL!, settings: recordSettings)
            self.audioRecorder!.isMeteringEnabled = true
            self.audioRecorder!.prepareToRecord()
            
        } catch {}
    }
    
    @IBAction func recordTapped(_ button: UIButton) {
        if self.audioRecorder!.isRecording {
            self.audioRecorder!.stop()
            button.setTitle("RECORD", for: UIControlState())
        } else {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                self.audioRecorder!.record()
                button.setTitle("STOP", for: UIControlState())
            } catch {}
        }
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        
        if self.audioPlayer == nil {
            setUpAndPlay()
        } else {
            if self.audioPlayer!.isPlaying {
                self.audioPlayer!.stop()
                self.playButton.setTitle("PLAY", for: UIControlState())
            } else {
                setUpAndPlay()
            }
        }
    }
    
    func setUpAndPlay() {
        do {
            self.audioPlayer =  try AVAudioPlayer(contentsOf: self.audioURL!)
            self.audioPlayer!.enableRate = true
            self.audioPlayer!.rate = self.rate
            if self.loopSwitch.isOn {
                self.audioPlayer!.numberOfLoops = -1
            }
            self.audioPlayer!.delegate = self
            self.audioPlayer!.play()
            self.playButton.setTitle("STOP", for: UIControlState())
        } catch {}
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playButton.setTitle("PLAY", for: UIControlState())
    }
    
    @IBAction func sliderMoved(_ slider: UISlider) {
        self.rate = 0.2
        self.rate += (slider.value * 3.8)
        
        let stringRate = String(format: "%.1f", self.rate)
        self.speedLabel.text = "Speed \(stringRate)x"
        
        if self.audioPlayer != nil {
            self.audioPlayer!.rate = self.rate
        }
    }
}

