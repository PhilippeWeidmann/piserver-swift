//
//  InputBoy.swift
//  PiLights
//
//  Created by Philippe Weidmann on 10.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import AnyCodable

class ExecutionCommand: Codable {
    var command: String
    var params: [String: AnyCodable]
}

class CommandPayload: Codable {
    var devices: [DeviceArray]
    var execution: [ExecutionCommand]
}

class DeviceArray: Codable {
    var id: String
}

class Payload: Codable {
    var devices: [DeviceArray]?
    var commands: [CommandPayload]?
}

class InputBody: Codable {
    var intent: String
    var payload: Payload?
}
