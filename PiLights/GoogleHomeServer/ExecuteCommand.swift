//
//  ExecuteCommand.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import AnyCodable

class ExecuteCommand: Codable {
    var ids: [String]
    var status: String
    var states: [String: AnyCodable]

    init() {
        ids = [String]()
        status = "SUCCESS"
        states = [String: AnyCodable]()
    }
}
