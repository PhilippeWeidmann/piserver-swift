//
//  SQLiteStorage.swift
//  PiLights
//
//  Created by Philippe Weidmann on 15.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import SQLite

class SQLiteStorage {

    static let instance = SQLiteStorage()
    private var connection: Connection!

    private init() {

    }

    private func getConnection() -> Connection {
        if connection == nil {
            do {
                connection = try Connection("./pilights.sqlite")
            } catch {
                logger.error("SQL - Error creating connection")
            }
        }
        return connection
    }

    public func getRooms() -> [Room] {
        let sql = "SELECT id, name FROM room"
        let connection = getConnection()
        var rooms = [Room]()
        do {
            for row in try connection.prepare(sql) {
                rooms.append(Room(row: row))
            }
        } catch {
            logger.error("SQL - Error loading rooms \(error)")
        }
        return rooms
    }

    public func addRoom(_ room: Room) -> Room? {
        let sql = "INSERT INTO room(name) VALUES(?)"
        let connection = getConnection()
        do {
            let stmt = try connection.prepare(sql)
            try stmt.run(room.name)
            return Room(id: Int(connection.lastInsertRowid), name: room.name)
        } catch {
            logger.error("SQL - Error adding room \(error)")
            return nil
        }
    }

    public func updateDevice(_ device: Device) {
        let sql = "UPDATE device SET displayName=?, roomId=? WHERE id=?"
        let connection = getConnection()
        do {
            let stmt = try connection.prepare(sql)
            try stmt.run(device.name, device.roomId, device.id)
        } catch {
            logger.error("SQL - Error updating device \(error)")
        }
    }

    public func getDevices() -> [Device] {
        let sql = "SELECT * FROM device"
        let connection = getConnection()
        var devices = [Device]()
        do {
            for row in try connection.prepare(sql) {
                if((row[2] as! String) == DeviceType.dimmableLight.rawValue) {
                    devices.append(DimmableLight(row: row))
                } else if ((row[2] as! String) == DeviceType.beacon.rawValue){
                    devices.append(Beacon(row: row))
                } else if ((row[2] as! String) == DeviceType.thermometer.rawValue){
                    devices.append(Thermometer(row: row))
                }
            }
        } catch {
            logger.error("SQL - Error loading devices \(error)")
        }
        return devices
    }

    public func addDevice(_ device: Device) {
        let sql = "INSERT INTO device(id, displayName, type, roomId, value) VALUES(?,?,?,?,?)"
        let connection = getConnection()
        do {
            let stmt = try connection.prepare(sql)
            try stmt.run(device.id, device.name, device.type.rawValue, device.roomId, device.value)
        } catch {
            logger.error("SQL - Error adding device \(error)")
        }
    }

}
