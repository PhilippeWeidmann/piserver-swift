//
//  DimmableLight.swift
//  my-home
//
//  Created by Philippe Weidmann on 14.06.20.
//

import Foundation
import HAP
import KituraNet
import KituraWebSocket
import SQLite

class DimmableLight: Device {
    init(id: Int, name: String, value: Int, roomId: Int) {
        super.init(id: id, name: name, type: .dimmableLight, value: value, roomId: roomId)
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try values.decode(Int.self, forKey: .id),
            name: try values.decode(String.self, forKey: .name),
            value: try values.decode(Int.self, forKey: .value),
            roomId: try values.decode(Int.self, forKey: .roomId)
        )
    }

    convenience init(row: Statement.Element) {
        self.init(
            id: Int(row[0] as! Int64),
            name: row[1] as! String,
            value: Int(row[4] as! Int64),
            roomId: Int(row[3] as! Int64)
        )
    }

    func switchLight(on: Bool) {
        if on {
            if value == 0 {
                value = 100
                self.sendUpdatePacket()
            }
        } else {
            value = 0
            self.sendUpdatePacket()
        }
    }

    func setDim(percent: Int) {
        value = percent
        self.sendUpdatePacket()
    }

    override func toGoogleHomeSyncDevice() -> SyncDevice {
        let device = super.toGoogleHomeSyncDevice()
        device.traits = ["action.devices.traits.OnOff", "action.devices.traits.Brightness"]
        return device
    }

    override func toGoogleHomeQueryDevice() -> QueryDevice {
        let device = super.toGoogleHomeQueryDevice()
        device.on = value > 0
        device.brightness = value
        return device
    }
}
