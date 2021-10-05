//
//  SyncResponse.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class SyncResponse: Codable {
    var agentUserId: String
    var devices: [SyncDevice]

    init(agentUserId: String) {
        self.agentUserId = agentUserId
        self.devices = [SyncDevice]()
    }
}
