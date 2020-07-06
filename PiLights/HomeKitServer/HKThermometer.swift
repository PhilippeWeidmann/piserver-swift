//
//  HKThermometer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKThermometer: HAP.Accessory.Thermometer {
    
    init() {
        super.init(info: .init(name: "", serialNumber: ""))
    }
}
