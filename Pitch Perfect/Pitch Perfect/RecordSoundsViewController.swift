//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Josh Nerius on 3/11/15.
//  Copyright (c) 2015 Josh Nerius. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    var recordingInProgress:Bool!
    var recordingPaused:Bool!
    
    let statusMessagePaused      = "Recording Paused"
    let statusMessageInProgress  = "Recording in Progress..."
    let instructionMessageRecord = "Tap to Record"
    let instructionMessagePause  = "Tap to Pause"
    let instructionMessageResume = "Tap to Resume"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Before the view appears, hide the stop button and reset the status label
        stopRecordingButton.hidden = true
        
        statusLabel.hidden = true
        statusLabel.text = statusMessageInProgress
        
        // Set or re-set instruction label
        instructionLabel.text = instructionMessageRecord
        
        // Set state flags
        recordingInProgress = false
        recordingPaused = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func recordAudio(sender: UIButton) {
        // Check to see if we are already recording. If not, start. If we are, pause. 
        
        if (!recordingInProgress) {
            recordingInProgress = true
            // Update the status label, hide the stop button and disable the record button
            statusLabel.text = statusMessageInProgress
            statusLabel.hidden = false
            
            // Update instruction label
            instructionLabel.text = instructionMessagePause
            
            stopRecordingButton.hidden = false
            // recordButton.enabled = false
            
            // Get the doc directory path for our app
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            
            // Generate a file name. A sample filename: 03292015-095023.wav
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
            
            // Construct the file path to be used by the recorder
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            
            // Set up a recording session
            var session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker, error: nil)
            
            // Initialize the audio recorder and start the recording
            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } else {
            // If the recording is already paused, switch the labels and resume
            if (recordingPaused == true) {
                instructionLabel.text = instructionMessagePause
                statusLabel.text = statusMessageInProgress
                recordingPaused = false
                audioRecorder.record()
            // If the recording is not paused, switch the labels and pause
            } else {
                instructionLabel.text = instructionMessageResume
                statusLabel.text = statusMessagePaused
                recordingPaused = true
                audioRecorder.pause()
            }
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        // Re-enable record button, stop the audio recorder and deactivate the audio session
        recordButton.enabled = true
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        // If recording was successful, perform segue, passing the recordedAudio object to the next view
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("error")
            recordButton.enabled = true
            stopRecordingButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}

