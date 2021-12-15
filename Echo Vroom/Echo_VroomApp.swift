//
//  Echo_VroomApp.swift
//  Echo Vroom
//
//  Created by Ali Momeni on 12/1/20.
//

import SwiftUI

@main
struct Echo_VroomApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView(motion: MotionManager())
        }
        
    }
}

