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

public protocol DeviceUpdatedDelegate {
    func didUpdateValue(_ newValue: Int)
}

public enum DeviceType: String, Codable {
    case dimmableLight
    case beacon
    case thermometer
    case light
    case co2Sensor

    var googleValue: String {
        let values = [
            DeviceType.dimmableLight: "action.devices.types.LIGHT",
            DeviceType.light: "action.devices.types.LIGHT",
            DeviceType.beacon: "action.devices.types.THERMOSTAT",
            DeviceType.thermometer: "action.devices.types.THERMOSTAT",
            DeviceType.co2Sensor: "action.devices.types.THERMOSTAT",
        ]
        return values[self]!
    }
}

class Device: Codable, Equatable {
    var connection: WebSocketConnection?
    var id: Int
    var name: String
    var type: DeviceType
    var value: Int {
        didSet {
            delegate?.didUpdateValue(value)
        }
    }

    var roomId: Int
    var delegate: DeviceUpdatedDelegate?

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
            try? DeviceServer.sendPacket(Packet(type: .DEVICE_STATUS_PACKET, data: DeviceStatusPacket(deviceId: id, deviceValue: value)), to: connection)
        }
    }

    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }

    func toGoogleHomeSyncDevice() -> SyncDevice {
        return SyncDevice(id: "\(id)", roomHint: DeviceServer.instance.getRoomWith(id: roomId)?.name ?? "none", name: name, type: type.googleValue)
    }

    func toGoogleHomeQueryDevice() -> QueryDevice {
        return QueryDevice()
    }
}
