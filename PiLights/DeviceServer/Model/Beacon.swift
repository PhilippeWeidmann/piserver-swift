//
//  Beacon.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import SQLite

class Beacon: Device {
    init(id: Int, name: String, value: Double, roomId: Int) {
        super.init(id: id, name: name, type: .beacon, value: value, roomId: roomId)
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try values.decode(Int.self, forKey: .id),
            name: try values.decode(String.self, forKey: .name),
            value: try values.decode(Double.self, forKey: .value),
            roomId: try values.decode(Int.self, forKey: .roomId)
        )
    }

    convenience init(row: Statement.Element) {
        self.init(
            id: Int(row[0] as! Int64),
            name: row[1] as! String,
            value: row[4] as! Double,
            roomId: Int(row[3] as! Int64)
        )
    }

    override func toGoogleHomeSyncDevice() -> SyncDevice {
        let device = super.toGoogleHomeSyncDevice()
        device.traits = ["action.devices.traits.SensorState"]
        return device
    }

    override func toGoogleHomeQueryDevice() -> QueryDevice {
        let device = super.toGoogleHomeQueryDevice()
        device.thermostatTemperatureAmbient = value
        return device
    }
}
