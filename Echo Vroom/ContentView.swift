//
//  ContentView.swift
//  Echo Vroom
//
//  Created by Ali Momeni on 12/1/20.
//

import SwiftUI
import CoreMotion
import AudioKit
import AudioToolbox


struct Constants {
    static let sensorUpdateInterval = 0.1
    static let senstorUpdateFrequency = 1 / sensorUpdateInterval
}

struct ContentView: View {
    
    
    
    @ObservedObject var conductor = RecorderConductor()
    @ObservedObject var motion =  MotionManager ()
    
    @State private var accelY: Double = 0.0

    var body: some View {

        VStack {


            Spacer()
            Text(conductor.data.isRecording ? "STOP RECORDING" : "RECORD")
                .onTapGesture {self.conductor.data.isRecording.toggle()
            }
            Spacer()
            Text(conductor.data.isPlaying ? "STOP" : "PLAY")
                .onTapGesture {self.conductor.data.isPlaying.toggle()
            }
            Spacer()
            //Slider(value: $motion.accelY)
            
            //PlotView(view: conductor.plot)
            
            Spacer()
//            Text("Accelerometer Data")
//            Text("y: \(motion.accelY)")


        }

        .padding()
        .navigationBarTitle(Text("Recorder"))
        .onAppear {
            self.conductor.start()
            self.motion.recorderConductorHandler = self.conductor

        }
        .onDisappear {
            self.conductor.stop()
        }
  
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(motion: MotionManager())

    }
}

