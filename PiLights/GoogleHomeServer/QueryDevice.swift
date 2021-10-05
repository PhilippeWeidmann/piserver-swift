//
//  DeviceQuery.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class QueryDevice: Codable {
    var online: Bool = true
    var on: Bool?
    var brightness: Int?
    var thermostatTemperatureAmbient: Int?
}
