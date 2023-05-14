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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main,
                                                   withHandler: { data, error in
                if let unwrapped = data?.pressure {
                    self.pressure.text = String.init(format: "%.2f mmHg", self.kPAToMmHg(value: unwrapped.floatValue))
                }
            })
        } else {
            print("Altimeter not available")
        }
    }

    func kPAToMmHg(value: Float) -> Float {
        return value * 7.5
    }
}

