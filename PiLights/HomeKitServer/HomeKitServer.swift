//
//  HomeKitServer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 15.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP
import Logging

class HomeKitServer {

    static let instance = HomeKitServer()
    private let server: HAP.Server?
    private let bridge: HAP.Device
    private let accessories = [Accessory]()


    private init() {
        bridge = HAP.Device(bridgeInfo: Service.Info(name: "Home Test", serialNumber: "A1"), setupCode: "123-44-321", storage: FileStorage(filename: "configuration.json"), accessories: accessories)
        do {
            server = try HAP.Server(device: bridge, listenPort: 0)
            logger.info("HomeKitServer started")
        } catch {
            server = nil
            logger.error("Error while starting HomeKit server \(error)")
        }
    }
    
    public func addAccessory(device: Device) {
        if device.type == .dimmableLight {
            bridge.addAccessories([HKDimmableLight(light: device as! DimmableLight)])
        } else if device.type == .beacon {
            bridge.addAccessories([HKBeacon(beacon: device as! Beacon)])
        }
    }
    
    public func stop() {
        do {
            try server?.stop()
        } catch {
            logger.error("Error while stoping HomeKit server")
        }
        
    }
}
