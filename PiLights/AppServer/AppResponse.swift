//
//  AppResponse.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class AppResponse<Content: Codable>: Codable {
    
    var status: String
    var message: String
    var data: Content?
    
    init(status: String, message: String, data: Content?) {
        self.status = status
        self.message = message
        self.data = data
    }
}
