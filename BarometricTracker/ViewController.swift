//
//  ViewController.swift
//  BarometricTracker
//
//  Created by Trent You on 2023-04-10.
//

import UIKit
import CoreMotion
import CoreLocation
import BackgroundTasks

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var pressure: UILabel!
    let altimeter = CMAltimeter()
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = true
        // locationManager?.startUpdatingLocation()
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main,
                                                   withHandler: { data, error in
                if let unwrapped = data?.pressure {
                    self.pressure.text = String.init(format: "%.2f hPA", self.kPAToMmHg(value: unwrapped.floatValue))
                }
            })
        } else {
            print("Altimeter not available")
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.BarometricTracker.getBarometricPressure", using: nil) { task in
             self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let operation = Operation()
        task.expirationHandler = {
            operation.cancel()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        operationQueue?.addOperation(operation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("Authorized")
        } else {
            print("Not authorized")
        }
    }
    

    func kPAToMmHg(value: Float) -> Float {
        return value * 7.5
    }


}

