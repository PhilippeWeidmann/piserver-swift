//
//  ExecuteResponse.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class ExecuteResponse: Codable {
    var commands: [ExecuteCommand]
    init() {
        commands = [ExecuteCommand]()
    }
}
