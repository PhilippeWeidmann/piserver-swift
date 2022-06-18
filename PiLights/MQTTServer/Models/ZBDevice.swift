//
//  MQTTDevice.swift
//  PiLights
//
//  Created by Philippe Weidmann on 22.02.22.
//  Copyright © 2022 Philippe Weidmann. All rights reserved.
//

import Foundation

class ZBDevice: Decodable {
    let ieeeAddress: String
    let type: String
    let friendlyName: String
    let supported: Bool
    let definition: ZBDefinition?
    let interviewing: Bool
    let interviewCompleted: Bool
}
