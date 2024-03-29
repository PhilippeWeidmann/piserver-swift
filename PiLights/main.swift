//
//  main.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP
import Kitura
import Logging

var logger = Logger(label: "ch.Pilights")
logger.logLevel = .info

var keepRunning = true

func stop() {
    HomeKitServer.instance.stop()
    DispatchQueue.main.async {
        keepRunning = false
    }
}

let homeKitServerThread = DispatchQueue(label: "HomeKitServer", attributes: .concurrent)

homeKitServerThread.async {
    _ = HomeKitServer.instance
}

let mqttServer = MQTTServer.instance

DeviceServer.instance.startServer()

let appServer = AppServer()
let googleHomeServer = GoogleHomeServer()

let webServerThread = DispatchQueue(label: "WebServer", attributes: .concurrent)

webServerThread.async {
    Kitura.run()
}

signal(SIGINT) { _ in stop() }
signal(SIGTERM) { _ in stop() }

while keepRunning {
    RunLoop.current.run(mode: .default, before: Date.distantFuture)
}
