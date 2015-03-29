//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Josh Nerius on 3/22/15.
//  Copyright (c) 2015 Josh Nerius. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize audio player using the input RecordedAudio object passed in by RecordSoundsViewController
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        
        // Initialize an audio engine against the same recieved audio for use by effects that require an engine for playback
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playFast(sender: UIButton) {
        audioPlayer.rate = 2.0
        play()
    }
    
    @IBAction func playSlow(sender: UIButton) {
        audioPlayer.rate = 0.5
        play()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playReverb(sender: UIButton) {
        playAudioWithReverb(AVAudioUnitReverbPreset.Cathedral, wetDryMix: 60)
    }
    
    
    @IBAction func playEcho(sender: UIButton) {
        playAudioWithDistortion(AVAudioUnitDistortionPreset.MultiEcho1)
    }
    
    @IBAction func stop(sender: UIButton) {
        stopAndResetAll()
    }
    
    // Play the recorded sound with an audio distortion preset
    func playAudioWithDistortion(preset: AVAudioUnitDistortionPreset) {
        stopAndResetAll()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var audioUnitDistortion = AVAudioUnitDistortion()
        audioUnitDistortion.loadFactoryPreset(preset)
        
        audioEngine.attachNode(audioUnitDistortion)
        audioEngine.connect(audioPlayerNode, to: audioUnitDistortion, format: nil)
        audioEngine.connect(audioUnitDistortion, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    // Play the recorded audio with a reverb preset and wet/dry mix
    func playAudioWithReverb(preset: AVAudioUnitReverbPreset, wetDryMix: Float) {
        stopAndResetAll()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var audioUnitReverb = AVAudioUnitReverb()
        audioUnitReverb.loadFactoryPreset(preset)
        audioUnitReverb.wetDryMix = wetDryMix
        
        audioEngine.attachNode(audioUnitReverb)
        audioEngine.connect(audioPlayerNode, to: audioUnitReverb, format: nil)
        audioEngine.connect(audioUnitReverb, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    // Play the recorded sound with variable pitch
    func playAudioWithVariablePitch(pitch: Float) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        
        audioPlayerNode.play()
    }
    
    // Use to stop and reset everything at once
    func stopAndResetAll() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func play() {
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.stop()
        
        audioPlayer.currentTime = 0
        audioPlayer.play()
    }
}
