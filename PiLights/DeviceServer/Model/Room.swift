//
//  Room.swift
//  PiLights
//
//  Created by Philippe Weidmann on 15.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import SQLite

class Room: Codable {
    
    let id: Int
    let name: String
    var devices: [Device]
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.devices = [Device]()
    }
    
    convenience init(row: Statement.Element) {
        self.init(
            id: Int(row[0] as! Int64),
            name: row[1] as! String
        )
    }

    func removeDevice(_ toRemoveDevice: Device) {
        devices.removeAll { (device) -> Bool in
            return toRemoveDevice == device
        }
    }
    
    func addDevice(_ newDevice: Device) {
        devices.append(newDevice)
    }
}
