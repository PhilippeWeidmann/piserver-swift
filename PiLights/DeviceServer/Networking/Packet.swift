//
//  Packet.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class Packet<PacketData: Codable>: Codable {
    
    enum PacketType : Int, Codable {
        case DEVICE_STATUS_PACKET = 1
        case REGISTER_DEVICE_PACKET = 2
        case DEVICE_REGISTERED_PACKET = 3
    }
    
    public var type: PacketType
    public var data: PacketData
    
    public init(type: PacketType, data: PacketData) {
        self.type = type
        self.data = data
    }
    
}

class BasePacket: Codable  {
    
}
