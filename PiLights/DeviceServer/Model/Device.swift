//
//  Device.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import KituraNet
import KituraWebSocket

public enum DeviceType: String, Codable {
    case dimmableLight
    case beacon
}

class Device: Codable, Equatable {

    var connection: WebSocketConnection?
    var id: Int
    var name: String
    var type: DeviceType
    var value: Int
    var roomId: Int

    enum CodingKeys: CodingKey {
        case id
        case name
        case type
        case value
        case roomId
    }

    init(id: Int, name: String, type: DeviceType, value: Int, roomId: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.value = value
        self.roomId = roomId
    }

    public func sendUpdatePacket() {
        logger.debug("Update packet value: \(value) for device: \(id)")
        if let connection = connection {
            try? DeviceServer.sendPacket(Packet(type: .DEVICE_STATUS_PACKET, data: DeviceStatusPacket(deviceId: self.id, deviceValue: "\(self.value)")), to: connection)
        }
    }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
    
}
