//
//  DeviceOrientationHelper.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/01.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit
import RxCocoa
import RxSwift

class DeviceOrientationHelper: NSObject {
    static let shared = DeviceOrientationHelper() // Singleton is recommended because an app should create only a single instance of the CMMotionManager class.
    
    private let motionManager: CMMotionManager
    private let queue: OperationQueue
    
    typealias DeviceOrientationHandler = ((_ deviceOrientation: UIDeviceOrientation) -> Void)?
    private var deviceOrientationAction: DeviceOrientationHandler?

    fileprivate var currentDeviceOrientaionBehaviorRelay = BehaviorRelay<UIDeviceOrientation>(value: .portrait)
    
    var currentOrientation: UIDeviceOrientation {
        get{
            self.currentDeviceOrientaionBehaviorRelay.value
        }
    }
    
    /// Smallers values makes it much sensitive to detect an orientation change. [0 to 1]
    private let motionLimit: Double = 0.6
    
    override init() {
        motionManager = CMMotionManager()
        // Specify an update interval in seconds, personally found this value provides a good UX
        motionManager.accelerometerUpdateInterval = 0.2
        queue = OperationQueue()
    }
    
    public func startDeviceOrientationNotifier() {
        
        motionManager.startAccelerometerUpdates(to: queue) { (data, error) in
            if let accelerometerData = data {
                var newDeviceOrientation: UIDeviceOrientation = .portrait
                
//                if (accelerometerData.acceleration.x >= self.motionLimit) {
//                    newDeviceOrientation = .landscapeLeft
//                }
//                else
                if (accelerometerData.acceleration.x <= -self.motionLimit) {
                    newDeviceOrientation = .landscapeRight
                }
                else if (accelerometerData.acceleration.y <= -self.motionLimit) {
                    newDeviceOrientation = .portrait
                }
//                else if (accelerometerData.acceleration.y >= self.motionLimit) {
//                    newDeviceOrientation = .portraitUpsideDown
//                }
                else {
                    return
                }
                
                self.currentDeviceOrientaionBehaviorRelay.accept(newDeviceOrientation)
                
            }
        }
    }
    
    public func stopDeviceOrientationNotifier() {
        motionManager.stopAccelerometerUpdates()
    }
}

extension Reactive where Base : DeviceOrientationHelper{
    var currentOrientation : Observable<UIDeviceOrientation>{
        get{
            return base.currentDeviceOrientaionBehaviorRelay.distinctUntilChanged().asObservable().observeOn(MainScheduler.instance).throttle(.seconds(1), scheduler: MainScheduler.instance)
        }
    }
}
