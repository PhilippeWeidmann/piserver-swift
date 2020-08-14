//
//  HKThermometer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKThermometer: HAP.Accessory.Thermometer, DeviceUpdatedDelegate {
    private let thermometer: PiLights.Thermometer

    init(thermometer: PiLights.Thermometer) {
        self.thermometer = thermometer
        super.init(info: .init(name: thermometer.name, serialNumber: "\(thermometer.id)"))
        self.thermometer.delegate = self
        self.temperatureSensor.currentTemperature.value = Float(thermometer.value)
    }

    func didUpdateValue(_ newValue: Int) {
        self.temperatureSensor.currentTemperature.value = Float(thermometer.value)
    }

}
