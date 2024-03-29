//
//  DeviceServer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 14.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import Kitura
import KituraNet
import KituraWebSocket
import Logging

class DeviceServer: WebSocketService {
    private let deviceServerThread = DispatchQueue(label: "DeviceServer", attributes: .concurrent)

    static let instance = DeviceServer()
    private var connections = [String: WebSocketConnection]()
    private var jsonDecoder = JSONDecoder()
    private static var jsonEncoder = JSONEncoder()

    let connectionTimeout: Int? = 60

    var devices = [Device]()
    var rooms = [Room]()

    private init() {
        rooms = SQLiteStorage.instance.getRooms()
        devices = SQLiteStorage.instance.getDevices()

        for device in devices {
            HomeKitServer.instance.addAccessory(device: device)
            if let room = getRoomWith(id: device.roomId) {
                room.devices.append(device)
            }
        }
    }

    public func startServer() {
        deviceServerThread.async {
            WebSocket.register(service: self, onPath: "")
            let server = HTTP.createServer()

            do {
                try server.listen(on: 10069)
                logger.info("DeviceServer started")
                ListenerGroup.waitForListeners()
            } catch {
                logger.error("Error starting DeviceServer \(error)")
            }
        }
    }

    public func connected(connection: WebSocketConnection) {
        connections[connection.id] = connection
    }

    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        if let device = getDeviceFor(connection: connection) {
            device.connection = nil
        }
        connections.removeValue(forKey: connection.id)
    }

    public func received(message: Data, from: WebSocketConnection) {
        closeConnection(from)
    }

    func closeConnection(_ connection: WebSocketConnection) {
        connection.close(reason: .invalidDataType, description: "Invalid protocol")

        connections.removeValue(forKey: connection.id)
    }

    public func received(message: String, from: WebSocketConnection) {
        do {
            let packet = try jsonDecoder.decode(Packet<BasePacket>.self, from: message.data(using: .utf8)!)
            let device = getDeviceFor(connection: from)

            if device == nil && packet.type != .REGISTER_DEVICE_PACKET {
                closeConnection(from)
                return
            }

            switch packet.type {
            case .REGISTER_DEVICE_PACKET:
                let registerDevicePacket = try jsonDecoder.decode(Packet<RegisterDevicePacket>.self, from: message.data(using: .utf8)!)
                let resultPacket = DeviceRegisteredPacket(result: "fail")

                if let newDevice = getDeviceWith(id: registerDevicePacket.data.deviceId) {
                    resultPacket.result = "ok"
                    newDevice.connection = from
                } else {
                    var newDevice: Device!
                    if registerDevicePacket.data.deviceType == "dimmable" {
                        newDevice = DimmableLight(id: registerDevicePacket.data.deviceId, name: "Dimmable Light", value: 0, roomId: 1)
                    } else if registerDevicePacket.data.deviceType == "beacon" {
                        newDevice = Beacon(id: registerDevicePacket.data.deviceId, name: "Beacon", value: registerDevicePacket.data.deviceValue ?? 0, roomId: 1)
                    } else if registerDevicePacket.data.deviceType == "thermometer" {
                        newDevice = Thermometer(id: registerDevicePacket.data.deviceId, name: "Thermometer", value: 20, roomId: 1)
                    } else if registerDevicePacket.data.deviceType == "light" {
                        newDevice = Light(id: registerDevicePacket.data.deviceId, name: "Light", value: 0, roomId: 1)
                    } else if registerDevicePacket.data.deviceType == "co2sensor" {
                        newDevice = CO2Sensor(id: registerDevicePacket.data.deviceId, name: "Co2Sensor", value: 0, roomId: 1)
                    }

                    if newDevice != nil {
                        resultPacket.result = "ok"
                        newDevice.connection = from

                        devices.append(newDevice)
                        if let room = getRoomWith(id: newDevice.roomId) {
                            room.addDevice(newDevice)
                        }
                        logger.info("Registering new device \(newDevice.id)")
                        SQLiteStorage.instance.addDevice(newDevice)
                    }
                }
                try DeviceServer.sendPacket(Packet(type: .DEVICE_REGISTERED_PACKET, data: resultPacket), to: from)
            case .DEVICE_STATUS_PACKET:
                let deviceStatusPacket = try jsonDecoder.decode(Packet<DeviceStatusPacket>.self, from: message.data(using: .utf8)!)

                if let thermometer = getDeviceWith(id: deviceStatusPacket.data.deviceId) as? Thermometer {
                    thermometer.value = deviceStatusPacket.data.deviceValue
                } else if let co2Sensor = getDeviceWith(id: deviceStatusPacket.data.deviceId) as? CO2Sensor {
                    co2Sensor.value = deviceStatusPacket.data.deviceValue
                }
            default:
                closeConnection(from)
            }
        } catch {
            closeConnection(from)
        }
    }

    static func sendPacket<T>(_ packet: Packet<T>, to: WebSocketConnection) throws {
        to.send(message: String(data: try jsonEncoder.encode(packet), encoding: .utf8) ?? "")
    }

    func getDeviceFor(connection: WebSocketConnection) -> Device? {
        return devices.first { device -> Bool in
            device.connection?.id == connection.id
        }
    }

    func getDeviceWith(id: Int) -> Device? {
        return devices.first { device -> Bool in
            device.id == id
        }
    }

    func getRoomWith(id: Int) -> Room? {
        return rooms.first { room -> Bool in
            room.id == id
        }
    }
}
