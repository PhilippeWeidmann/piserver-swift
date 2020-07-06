//
//  RegisterDevicePacket.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class RegisterDevicePacket: Codable {
    
    public let deviceId: Int
    public let deviceType: String
    public let deviceValue: Int?
}
