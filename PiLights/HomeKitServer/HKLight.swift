//
//  HKLight.swift
//  PiLights
//
//  Created by Philippe Weidmann on 01.09.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKLight: HAP.Accessory.Lightbulb, DeviceUpdatedDelegate {
    private let light: Light

    init(light: Light) {
        self.light = light
        super.init(info: .init(name: light.name, serialNumber: "\(light.id)"), additionalServices: [], type: .monochrome, isDimmable: false)
        self.reachable = true
        self.light.delegate = self
        self.didUpdateValue(self.light.value)
    }

    func didUpdateValue(_ newValue: Double) {
        self.lightbulb.powerState.value = newValue != 0
    }

    override func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, didChangeValue newValue: T?) where T: CharacteristicValueType {
        if characteristic === self.lightbulb.powerState {
            self.light.switchLight(on: newValue as! Bool)
        }
        super.characteristic(characteristic, ofService: service, didChangeValue: newValue)
    }
}
