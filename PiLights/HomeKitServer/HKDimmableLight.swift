//
//  HKDimmableLight.swift
//  PiLights
//
//  Created by Philippe Weidmann on 15.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class HKDimmableLight: HAP.Accessory.Lightbulb {
    
    private let light: DimmableLight
    
    init(light: DimmableLight) {
        self.light = light
        super.init(info: .init(name: light.name, serialNumber: "\(light.id)"), additionalServices: [], type: .monochrome, isDimmable: true)
        self.reachable = true
        self.updateValues()
    }
    
    func updateValues() {
        self.lightbulb.powerState.value = light.value != 0
        self.lightbulb.brightness?.value = light.value
    }

    override func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, didChangeValue newValue: T?) where T: CharacteristicValueType {
        if characteristic === self.lightbulb.powerState {
            light.switchLight(on: (newValue as! Bool))
        } else if characteristic === self.lightbulb.brightness {
            light.setDim(percent: (newValue as! Int))
        }
        
        super.characteristic(characteristic, ofService: service, didChangeValue: newValue)
    }
}
