import AudioKit
import AVFoundation
import SwiftUI

// Helper functions
class Cookbook {
    static var sourceBuffer: AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }

    static func loadBuffer(filePath: String) -> AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent(filePath)
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }
    
    static func scale (_ input: Double,_ inputLow: Double,_ inputHigh: Double,_  outputLow: Double,_ outputHigh: Double) -> Double {
        let result = ((input - inputLow) / (inputHigh - inputLow)) * (outputHigh - outputLow) + outputLow
        return result
    }
    

}
