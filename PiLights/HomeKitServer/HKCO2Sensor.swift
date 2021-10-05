//
//  CO2Sensor.swift
//  PiLights
//
//  Created by Philippe Weidmann on 04.10.21.
//  Copyright © 2021 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKCO2Sensor: Accessory {
    private let sensor: CO2Sensor
    let service = Service.CarbonDioxideSensor()
    init(sensor: CO2Sensor) {
        self.sensor = sensor
        super.init(info: .init(name: sensor.name, serialNumber: "\(sensor.id)"), type: .sensor, services: [service])
        self.reachable = true
        service.carbonDioxideLevel?.value = 900
    }

    func didUpdateValue(_ newValue: Int) {
        service.carbonDioxideLevel?.value = Float(sensor.value)
    }
}
