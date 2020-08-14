//
//  DeviceStatusPacket.swift
//  PiLights
//
//  Created by Philippe Weidmann on 15.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class DeviceStatusPacket: Codable {
    
    public let deviceId: Int
    public let deviceValue: Int
    
    public init(deviceId: Int, deviceValue: Int) {
        self.deviceId = deviceId
        self.deviceValue = deviceValue
    }
}

