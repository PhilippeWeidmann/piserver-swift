//
//  SyncDevice.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import AnyCodable

class SyncDevice: Codable {
    var id: String
    var traits: [String]!
    var roomHint: String
    var name: [String: String]
    var type: String
    var attributes: [String: AnyCodable]?

    init(id: String, roomHint: String, name: String, type: String) {
        self.id = id
        self.name = ["name": name]
        self.roomHint = roomHint
        self.type = type
    }
}
