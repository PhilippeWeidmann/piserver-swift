//
//  CO2Sensor.swift
//  PiLights
//
//  Created by Philippe Weidmann on 04.10.21.
//  Copyright © 2021 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKCO2Sensor: Accessory, DeviceUpdatedDelegate {
    private let sensor: CO2Sensor
    let service = Service.CarbonDioxideSensor(characteristics: [AnyCharacteristic(GenericCharacteristic<Float>(type: .carbonDioxideLevel, value: 700, permissions: [.read, .events]))])
    init(sensor: CO2Sensor) {
        self.sensor = sensor
        super.init(info: .init(name: sensor.name, serialNumber: "\(sensor.id)"), type: .sensor, services: [service])
        self.sensor.delegate = self
        self.reachable = true
        service.carbonDioxideDetected.value = .normal
        service.carbonDioxideLevel?.value = 700
    }

    func didUpdateValue(_ newValue: Int) {
        service.carbonDioxideDetected.value = sensor.value > 1800 ? .abnormal : .normal
        service.carbonDioxideLevel?.value = Float(sensor.value)
    }
}
