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
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
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
        playAtSpecifiedRate(2.0)
    }
    
    @IBAction func playSlow(sender: UIButton) {
        playAtSpecifiedRate(0.5)
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
    
    // Play audio with specified effect
    func playAudioWithEffect(effect: AVAudioUnit) {
        stopAndResetAll()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(effect)
        
        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    // Play the recorded sound with an audio distortion preset
    func playAudioWithDistortion(preset: AVAudioUnitDistortionPreset) {
        var audioUnitDistortion = AVAudioUnitDistortion()
        audioUnitDistortion.loadFactoryPreset(preset)
        
        playAudioWithEffect(audioUnitDistortion)
    }
    
    // Play the recorded audio with a reverb preset and wet/dry mix. Takes two
    // params: preset and wetDryMix. This will let us easily configure the app
    // to user other reverb variants in the future.
    func playAudioWithReverb(preset: AVAudioUnitReverbPreset, wetDryMix: Float) {
        var audioUnitReverb = AVAudioUnitReverb()
        audioUnitReverb.loadFactoryPreset(preset)
        audioUnitReverb.wetDryMix = wetDryMix
        
        playAudioWithEffect(audioUnitReverb)
    }
    
    // Play the recorded sound with variable pitch
    func playAudioWithVariablePitch(pitch: Float) {
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        playAudioWithEffect(changePitchEffect)
    }
    
    // Use to stop and reset everything at once
    func stopAndResetAll() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAtSpecifiedRate(rate: Float) {
        stopAndResetAll()
        audioPlayer.rate = rate;
        audioPlayer.play()
    }
}