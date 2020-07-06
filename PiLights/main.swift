//
//  main.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP
import Logging

let logger = Logger(label: "ch.Pilights")
var keepRunning = true

func stop() {
    HomeKitServer.instance.stop()
    DispatchQueue.main.async {
        keepRunning = false
    }
}

let homeKitServerThread = DispatchQueue(label: "HomeKitServer", attributes: .concurrent)

homeKitServerThread.async {
    let _ = HomeKitServer.instance
}


DeviceServer.instance.startServer()

let appServerThread = DispatchQueue(label: "AppServer", attributes: .concurrent)

appServerThread.async {
    let _ = AppServer()
}

signal(SIGINT) { _ in stop() }
signal(SIGTERM) { _ in stop() }


while keepRunning {
    RunLoop.current.run(mode: .default, before: Date.distantFuture)
}

