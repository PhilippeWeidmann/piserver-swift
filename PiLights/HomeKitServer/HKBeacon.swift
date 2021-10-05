//
//  HKBeacon.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKBeacon: Accessory {
    let service = BeaconService()
    init(beacon: Beacon) {
        super.init(info: .init(name: beacon.name, serialNumber: "\(beacon.id)"), type: .sensor, services: [service])
    }
}

class BeaconService: Service {
    public let occupancy = GenericCharacteristic<Bool>(
        type: .occupancyDetected,
        value: false)

    init() {
        super.init(type: .occupancySensor, characteristics: [
            AnyCharacteristic(occupancy)
        ])
    }
}
