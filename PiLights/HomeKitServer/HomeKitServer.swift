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

    private init() {
        bridge = HAP.Device(bridgeInfo: Service.Info(name: "Home Test", serialNumber: "A1"), setupCode: "123-44-321", storage: FileStorage(filename: "configuration.json"), accessories: [])
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
        } else if device.type == .thermometer {
            bridge.addAccessories([HKThermometer(thermometer: device as! Thermometer)])
        } else if device.type == .light {
            bridge.addAccessories([HKLight(light: device as! Light)])
        } else if device.type == .co2Sensor {
            bridge.addAccessories([HKCO2Sensor(sensor: device as! CO2Sensor)])
        }
    }

    public func addOrUpdateAccessory(accessory: ZBAccessory) -> ZBAccessory?  {
        if let existingAccessory = bridge.accessories.first(where: {$0.serialNumber == accessory.serialNumber}) {
            if let existingAccessory = existingAccessory as? ZBAccessory {
                logger.info("Updating accessory (if the accessory doesn't contain the same services this might create a bug)")
                existingAccessory.zbDevice = accessory.zbDevice
                return existingAccessory
            } else {
                logger.error("Found accessory which was not previously a ZBAccessory")
                return nil
            }
        } else {
            bridge.addAccessories([accessory])
            return accessory
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
