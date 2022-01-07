//
//  RecorderConductor.swift
//  Echo Vroom
//
//  Created by Ali Momeni on 11/30/20.
//

import Foundation

import AVFoundation
import AudioKit
import AudioKitEX
import AudioToolbox
import SoundpipeAudioKit
import CoreMotion
import SwiftUI

// For manging recording state
struct RecorderData {
    var isRecording = false
    var isPlaying = false

}

class RecorderConductor: ObservableObject {
            
    // For audio playback
    let engine = AudioEngine()
    let player = AudioPlayer()
    let mixer = Mixer()
    let variSpeed: VariSpeed
    var env: AmplitudeEnvelope
    //var plot: NodeOutputPlot
    
    
    // For audio recording
    let recorder: NodeRecorder
    var silencer: Fader?
    
    // For switchin buffers
    var playDirection : Int = 1// 0 for reverse, 1 for forwrd
    var playDirectionNew : Int = 1// used to detect direction changes
    var recordingExists = false
    var playDirectionChange: Int = 0// 0 for no, 1 for us
    
    // For CoreMotion
    // For sensor data
    // @ObservedObject var motion: MotionManager


        
    var buffer: AVAudioPCMBuffer
    var bufferReversed: AVAudioPCMBuffer

    @Published var playSpeed : Float {
        didSet {
//            Log("--------playSpeed:" + String(playSpeed))
            variSpeed.rate = abs(playSpeed)
            if ( playSpeed > 0) { playDirectionNew = 1 } else { playDirectionNew = 0 }
            if (playDirectionNew == playDirection) { } else { playDirectionChange = 1}
            
//            Log("---playDirection:" + String(playDirection))
//            Log("---playDirectionNew:" + String(playDirectionNew))
            if (playDirectionChange == 1) {
                Log("******PlayDirection Change")

                if (recordingExists) {
                    Log("***Recording Exists")
                    if (playDirection == 1) {
                        Log("*Forward")
                        player.stop()
                        player.scheduleBuffer(buffer, at: nil, options: .loops)
                        player.play()
                    } else {
                        Log("*Reverse")
                        player.stop()
                        player.scheduleBuffer(bufferReversed, at: nil, options: .loops)
                        player.play()

                    }
                }
                playDirectionChange = 0

            }
            
            playDirection = playDirectionNew
        }
    }

//    @Published var playDirectionChange : Int {
//        didSet {
//            if (playDirectionChange == 1 ) {
//                Log("***PlayDirection Change")
//                if (data.recordingExists) {
//                    if (playDirection == 1) {
//                        player.stop()
//                        player.scheduleBuffer(buffer, at: nil, options: .loops)
//                        player.play()
//                    } else {
//                        player.stop()
//                        player.scheduleBuffer(bufferReversed, at: nil, options: .loops)
//                        player.play()
//
//                    }
//                }
//            }
//
//            playDirectionChange = 0
//        }
//    }
    
    @Published var data = RecorderData() {
        didSet {
            if data.isRecording {
                NodeRecorder.removeTempFiles()
                do {
                    try recorder.record()
                } catch let err {
                    print(err)
                }
            } else {
                recorder.stop()
                //bufferReversed = buffer.reverse()!
                recordingExists = true
            }

            if data.isPlaying {
                if let file = recorder.audioFile {
                    if (recorder.isRecording) {
                        recorder.stop()
                        recordingExists = true
                    }
    
                    buffer = try! AVAudioPCMBuffer(file: file)!
                    bufferReversed = buffer.reverse()!
                    player.scheduleBuffer(bufferReversed, at: nil, options: .loops)
                    player.play()
                }
            } else {
                player.stop()
            }
        }
    }
    
    
    init() {
        
        
        // #if os(iOS)
        do {

            try Settings.session.setPreferredSampleRate(48000)
            
        } catch let err {
            print(err)
        }
        // #endif
        
        do {
            Settings.bufferLength = .short
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print(err)
        }
        
        
        guard let input = engine.input else {
            fatalError()
        }

        do {
            recorder = try NodeRecorder(node: input)
        } catch let err {
            fatalError("\(err)")
        }
        
        let silencer = Fader(input, gain: 0)
        self.silencer = silencer
        
        variSpeed = VariSpeed(player)
        
        mixer.addInput(silencer)
        //mixer.addInput(player)
        mixer.addInput(variSpeed)
        env = AmplitudeEnvelope(mixer)
        //plot = NodeOutputPlot(mixer)
        //plot.plotType = .rolling

        engine.output = mixer
        
        buffer = Cookbook.loadBuffer(filePath: "Sounds/echo_baba3.wav")
        bufferReversed = Cookbook.loadBuffer(filePath: "Sounds/echo_baba3.wav")

        playSpeed  = 1

//        playDirectionChange = 0
    }
    
    
    func start() {
        //plot.start()

        do {
            //variSpeed.rate = 1.0
            try engine.start()
        } catch let err {
            print(err)
        }
    }

    func stop() {
        engine.stop()
    }
    
}
