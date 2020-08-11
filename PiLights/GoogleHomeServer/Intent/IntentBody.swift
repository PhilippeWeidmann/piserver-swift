//
//  IntentBody.swift
//  PiLights
//
//  Created by Philippe Weidmann on 10.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class IntentBody: Codable {
    var inputs: [InputBody]
    var requestId: String
}
