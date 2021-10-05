//
//  QueryResponse.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class QueryResponse: Codable {
    var devices: [String: QueryDevice]

    init() {
        devices = [String: QueryDevice]()
    }
}
