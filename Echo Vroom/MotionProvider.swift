//
//  MotionProvider.swift
//  Echo Vroom
//
//  Created by Ali Momeni on 12/5/20.
//

import Foundation
import CoreMotion
import Combine


public class MotionProvider: NSObject, ObservableObject {

    public let objectWillChange = PassthroughSubject<CMAcceleration,Never>()

    public private(set) var acceleration: CMAcceleration = CMAcceleration() {
        willSet {
            objectWillChange.send(newValue)
        }
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }

    private var motionManager: CMMotionManager

    public override init(){
        self.motionManager = CMMotionManager()
        super.init()
        motionManager.magnetometerUpdateInterval = 1/60
    }
    
//    init(contentView : ContentView) {
//        self.motionManager = CMMotionManager()
//        super.init()
//        contentView.motionDelegate = self
//    }

    public func startUpdates() {
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { this, that in
            if let acceleration = self.motionManager.accelerometerData?.acceleration {
                self.acceleration = acceleration
            }
        }
    }
}
