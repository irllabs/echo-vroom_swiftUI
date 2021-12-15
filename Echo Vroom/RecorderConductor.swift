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
    var playSpeed : Float = 1
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
    
    // For CoreMotion
    // For sensor data
    // @ObservedObject var motion: MotionManager


        
    var buffer: AVAudioPCMBuffer
    
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
            }

            if data.isPlaying {
                if let file = recorder.audioFile {
                    if (recorder.isRecording) {
                        recorder.stop()
                    }
    
                    buffer = try! AVAudioPCMBuffer(file: file)!
                    player.scheduleBuffer(buffer, at: nil, options: .loops)
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
        
        guard let input = engine.input else {
            fatalError()
        }

        do {
            recorder = try NodeRecorder(node: input)
        } catch let err {
            fatalError("\(err)")
        }
        
        recorder.
        let silencer = Fader(input, gain: 0)
        self.silencer = silencer
        
        variSpeed = VariSpeed(player)
        
        mixer.addInput(silencer)
        mixer.addInput(player)
        mixer.addInput(variSpeed)
        env = AmplitudeEnvelope(mixer)
        //plot = NodeOutputPlot(mixer)
        //plot.plotType = .rolling

        engine.output = mixer
        
        buffer = Cookbook.loadBuffer(filePath: "Sounds/echo_baba3.wav")

    }
    
    
    func start() {
        //plot.start()

        do {
            variSpeed.rate = 1.0
            try engine.start()
        } catch let err {
            print(err)
        }
    }

    func stop() {
        engine.stop()
    }
    
}
