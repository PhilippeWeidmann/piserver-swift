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
    public let deviceValue: String
    
    public init(deviceId: Int, deviceValue: String) {
        self.deviceId = deviceId
        self.deviceValue = deviceValue
    }
}

