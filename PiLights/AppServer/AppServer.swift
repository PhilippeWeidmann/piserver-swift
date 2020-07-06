//
//  AppServer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import Kitura

class AppServer {

    let deviceServer = DeviceServer.instance
    let router = Router()

    init() {
        router.all(middleware: BodyParser())

        router.get("/rooms") { request, response, next in
            let appResponse = AppResponse<[Room]>(status: "ok", message: "", data: self.deviceServer.rooms)
            response.send(appResponse)
            next()
        }

        router.post("/rooms") { request, response, next in
            let appResponse = AppResponse<[Room]>(status: "ok", message: "", data: nil)
            if let body = request.body?.asURLEncoded,
                let newRoomName = self.getValueForPostBody(name: "roomName", body: body),
                let room = SQLiteStorage.instance.addRoom(Room(id: -1, name: newRoomName)) {
                self.deviceServer.rooms.append(room)
            } else {
                response.statusCode = HTTPStatusCode.badRequest
                appResponse.status = "error"
                appResponse.message = "bad request"
            }
            response.send(appResponse)
            next()
        }

        router.get("/devices") { request, response, next in
            print(DeviceServer.instance.devices)
            let appResponse = AppResponse<[Device]>(status: "ok", message: "", data: DeviceServer.instance.devices)
            response.send(appResponse)
            next()
        }

        router.post("/devices/:id") { request, response, next in
            if let requestId = request.parameters["id"],
                let id = Int(requestId),
                let device = self.deviceServer.getDeviceWith(id: id),
                let body = request.body?.asURLEncoded {
                if let newName = self.getValueForPostBody(name: "deviceName", body: body) {
                    if device.name != newName {
                        device.name = newName
                        SQLiteStorage.instance.updateDevice(device)
                    }
                }
                if let stringNewRoomId = self.getValueForPostBody(name: "roomId", body: body),
                    let newRoomId = Int(stringNewRoomId) {
                    if newRoomId != device.roomId {
                        DeviceServer.instance.getRoomWith(id: device.roomId)?.removeDevice(device)
                        device.roomId = newRoomId
                        DeviceServer.instance.getRoomWith(id: newRoomId)?.addDevice(device)
                        SQLiteStorage.instance.updateDevice(device)
                    }
                }
                if let stringNewValue = self.getValueForPostBody(name: "value", body: body),
                    let newValue = Int(stringNewValue) {
                    if let dimmableLight = device as? DimmableLight {
                        dimmableLight.setDim(percent: newValue)
                    } else {
                        device.value = newValue
                    }
                }
                if let stringOn = self.getValueForPostBody(name: "on", body: body),
                    let on = Bool(stringOn) {
                    if let dimmableLight = device as? DimmableLight {
                        dimmableLight.switchLight(on: on)
                    }
                }

                response.send(AppResponse<Device>(status: "ok", message: "", data: device))
            } else {
                response.statusCode = HTTPStatusCode.notFound
                response.send(AppResponse<String>(status: "error", message: "Device not found", data: nil))
            }
            next()
        }

        logger.info("AppServer starting")
        Kitura.addHTTPServer(onPort: 10068, with: router)
        Kitura.run()
    }


    func getValueForPostBody(name: String, body: [String : String]) -> String? {
        return body[name]
    }
}
