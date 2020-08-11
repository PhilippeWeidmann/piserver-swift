//
//  GoogleResponse.swift
//  PiLights
//
//  Created by Philippe Weidmann on 09.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class GoogleResponse<Response : Codable>: Codable {
    var payload: Response
    var requestId: String!
    
    init(payload: Response, requestId: String) {
        self.payload = payload
        self.requestId = requestId
    }
}
