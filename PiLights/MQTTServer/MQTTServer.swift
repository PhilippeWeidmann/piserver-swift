//
//  MQTTServer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 22.02.22.
//  Copyright © 2022 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP
import MQTTNIO

class MQTTServer {
    static let instance = MQTTServer()
    private let decoder = JSONDecoder()

    private let client = MQTTClient(
        host: "localhost",
        port: 1883,
        identifier: "PiLights",
        eventLoopGroupProvider: .createNew
    )

    private let deviceListTopic = MQTTSubscribeInfo(topicFilter: "zigbee2mqtt/bridge/devices", qos: .atLeastOnce)
    private var zbDevices = [String: ZBAccessory]()

    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        client.connect().whenComplete { [weak self] result in
            switch result {
            case .success:
                logger.info("Succesfully connected to MQTT")
                self?.subscribeForDeviceList()
            case .failure(let error):
                logger.error("Error while connecting \(error)")
            }
        }

        client.addPublishListener(named: "Main Listener") { [weak self] result in
            switch result {
            case .success(let infos):
                self?.handlePublishInfos(infos)
            case .failure(let error):
                logger.error("Error in main listener \(error)")
            }
        }
    }

    func handlePublishInfos(_ infos: MQTTPublishInfo) {
        do {
            // logger.debug("Message received \(String(data: Data(buffer: infos.payload), encoding: .utf8) ?? "No payload")")
            let topicName = infos.topicName
            switch topicName {
            case deviceListTopic.topicFilter:
                let devicesMessage = try decoder.decode([ZBDevice].self, from: infos.payload)
                handleDevicesMessage(devicesMessage)
            default:
                let splittedTopic = topicName.split(separator: "/")
                if topicName.starts(with: "zigbee2mqtt/"),
                   splittedTopic.count == 2,
                   let lastComponent = splittedTopic.last,
                   let accessory = zbDevices[String(lastComponent)],
                   let values = try? JSONSerialization.jsonObject(with: infos.payload, options: .mutableContainers) as? [String: AnyObject] {
                    accessory.updateCharacteristics(with: values)
                }
            }
        } catch {
            logger.error("Error while decoding publish info \(error)")
        }
    }

    func handleDevicesMessage(_ devices: [ZBDevice]) {
        for device in devices {
            if let definition = device.definition,
               !definition.exposes.isEmpty {
                if let accessory = ZBAccessory(zbDevice: device) {
                    HomeKitServer.instance.addAccessory(accessory: accessory)
                    zbDevices[device.friendlyName] = accessory
                }
            }
        }
    }

    func setBinaryFeature(_ feature: BinaryFeature, value: Bool, for device: ZBDevice) {
        let value = value ? feature.valueOn : feature.valueOff
        let topicName = topicNameFromDeviceAndFeature(feature: feature, device: device, set: true)
        client.publish(to: topicName, payload: .init(string: value), qos: .atLeastOnce).whenComplete { result in
            print(result)
        }
    }

    func setNumericFeature(_ feature: NumericFeature, value: Int, for device: ZBDevice) {
        let topicName = topicNameFromDeviceAndFeature(feature: feature, device: device, set: true)
        client.publish(to: topicName, payload: .init(string: "\(value)"), qos: .atLeastOnce).whenComplete { result in
            print(result)
        }
    }

    private func topicNameFromDeviceAndFeature(feature: NamedFeature, device: ZBDevice, set: Bool) -> String {
        if set {
            return "zigbee2mqtt/\(device.friendlyName)/set/\(feature.name.rawValue)"
        } else {
            return "zigbee2mqtt/\(device.friendlyName)/get/\(feature.name.rawValue)"
        }
    }

    func subscribeForDevices() {
        let mqttDeviceTopics = zbDevices.keys.map { MQTTSubscribeInfo(topicFilter: "zigbee2mqtt/\($0)", qos: .atLeastOnce) }
        client.subscribe(to: mqttDeviceTopics).whenComplete { result in
            switch result {
            case .success:
                logger.info("Succesfully subscribed to \(mqttDeviceTopics.map { $0.topicFilter })")
            case .failure(let error):
                logger.error("Error while subscribing for devices \(error)")
            }
        }
    }

    func subscribeForDeviceList() {
        client.subscribe(to: [deviceListTopic]).whenComplete { [topicFilter = deviceListTopic.topicFilter] result in
            switch result {
            case .success:
                logger.info("Succesfully subscribed to \(topicFilter)")
            case .failure(let error):
                logger.error("Error while subscribing for devices \(error)")
            }
        }
    }
}
