//
//  Light.swift
//  PiLights
//
//  Created by Philippe Weidmann on 01.09.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import SQLite

class Light: Device {

    init(id: Int, name: String, value: Int, roomId: Int) {
        super.init(id: id, name: name, type: .light, value: value, roomId: roomId)
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
        value = on ? 1 : 0
        self.sendUpdatePacket()
    }
    
    override func toGoogleHomeSyncDevice() -> SyncDevice {
        let device = super.toGoogleHomeSyncDevice()
        device.traits = ["action.devices.traits.OnOff"]
        return device
    }
    
    override func toGoogleHomeQueryDevice() -> QueryDevice {
        let device = super.toGoogleHomeQueryDevice()
        device.on = value > 0
        return device
    }
}
