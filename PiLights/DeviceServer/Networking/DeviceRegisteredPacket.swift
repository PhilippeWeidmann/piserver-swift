//
//  DeviceRegisteredPacket.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class DeviceRegisteredPacket: Codable {
    public var result: String

    init(result: String) {
        self.result = result
    }
}
