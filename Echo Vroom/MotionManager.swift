//
//  MotionManager.swift
//  Echo Vroom
//
//  Created by Ali Momeni on 12/5/20.
//

import Foundation


import Foundation
import Combine
import CoreMotion

class MotionManager: ObservableObject {

    private var motionManager: CMMotionManager
    
    
    // use as handle to modify the app'smain RecorderConductor class instance
    var recorderConductorHandler : RecorderConductor

    @Published
    var magX: Double = 0.0
    @Published
    var magY: Double = 0.0
    @Published
    var magZ: Double = 0.0

    @Published
    var accelX: Double = 0.0
    @Published
    var accelY: Double = 0.0
    @Published
    var accelZ: Double = 0.0

    init() {
        self.recorderConductorHandler = RecorderConductor()
        self.motionManager = CMMotionManager()
        self.motionManager.magnetometerUpdateInterval = 1/100
        self.motionManager.startMagnetometerUpdates(to: .main) { (magnetometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }

            if let magnetData = magnetometerData {
                self.magX = magnetData.magneticField.x
                self.magY = magnetData.magneticField.y
                self.magZ = magnetData.magneticField.z
            }

        }
        self.motionManager.accelerometerUpdateInterval = 1/100
        self.motionManager.startAccelerometerUpdates(to: .main) { [self] (accelerometterData, error) in
            guard error == nil else {
                print(error!)
                return
            }

            if let accelData = accelerometterData {
                self.accelX = accelData.acceleration.x
                self.accelY = accelData.acceleration.y
                self.accelZ = accelData.acceleration.z
                self.recorderConductorHandler.variSpeed.rate = Float(Cookbook.scale(self.accelY, -1, 1, -1, 3))

            }

        }
    }
}
