//
//  AppServer.swift
//  PiLights
//
//  Created by Philippe Weidmann on 17.06.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation
import Kitura
import AnyCodable

class GoogleHomeServer {

    let deviceServer = DeviceServer.instance
    let router = Router()

    init() {
        router.all(middleware: BodyParser())

        router.get("/fakeauth") { request, response, next in
            if let redirectUrl = request.queryParameters["redirect_uri"],
                let state = request.queryParameters["state"] {
                let responseURL = redirectUrl + "?code=fdasjafluudsadj54qrwqfafda$$&state=" + state
                let _ = try? response.redirect(responseURL)
            }
            next()
        }

        router.post("/faketoken") { request, response, next in
            if let grantType = self.getValueForPostBody(name: "grant_type", body: request.body?.asURLEncoded) {
                if grantType == "authorization_code" {
                    let authResponse = [
                        "token_type": "bearer",
                        "access_token": "123access",
                        "refresh_token": "123refresh",
                        "expires_in": 86400] as [String: Any]
                    response.send(json: authResponse)
                } else if grantType == "refresh_token" {
                    let refreshResponse = [
                        "token_type": "bearer",
                        "access_token": "123access",
                        "expires_in": 86400] as [String: Any]
                    response.send(json: refreshResponse)
                } else {

                }
            }
            next()
        }

        router.post("/smarthome") { request, response, next in
            if let body = request.body?.asJSON {
                do {
                    let intent = try JSONDecoder().decode(IntentBody.self, from: JSONSerialization.data(withJSONObject: body, options: []))
                    for input in intent.inputs {
                        if input.intent == "action.devices.SYNC" {
                            let syncResponse = self.handleSync(input: input)
                            response.send(GoogleResponse(payload: syncResponse, requestId: intent.requestId))
                        } else if input.intent == "action.devices.QUERY" {
                            let queryResponse = self.handleQuery(input: input)
                            response.send(GoogleResponse(payload: queryResponse, requestId: intent.requestId))
                        } else if input.intent == "action.devices.EXECUTE" {
                            let executeResponse = self.handleExecute(input: input)
                            response.send(GoogleResponse(payload: executeResponse, requestId: intent.requestId))
                        }
                    }
                } catch {
                    logger.error("Error for Google SmartHome:\n \(error)\nIntent:\(body)")
                }
            }
            next()
        }

        logger.info("GoogleHomeServer starting")
        Kitura.addHTTPServer(onPort: 10080, with: router)
    }

    func handleSync(input: InputBody) -> SyncResponse {
        let response = SyncResponse(agentUserId: "1836.15267389")
        for device in DeviceServer.instance.devices {
            response.devices.append(device.toGoogleHomeSyncDevice())
        }
        return response
    }

    func handleQuery(input: InputBody) -> QueryResponse {
        let response = QueryResponse()
        if let queryDevices = input.payload?.devices {
            for device in queryDevices {
                if let id = Int(device.id) {
                    response.devices["\(id)"] = DeviceServer.instance.getDeviceWith(id: id)?.toGoogleHomeQueryDevice()
                }
            }
        }
        return response
    }

    func handleExecute(input: InputBody) -> ExecuteResponse {
        let response = ExecuteResponse()
        if let commands = input.payload?.commands {
            for command in commands {
                let execCommand = ExecuteCommand()
                for device in command.devices {
                    execCommand.ids.append(device.id)
                    if let id = Int(device.id) {
                        if let device = DeviceServer.instance.getDeviceWith(id: id) {
                            for exec in command.execution {
                                if exec.command == "action.devices.commands.BrightnessAbsolute" {
                                    if let dimmableLight = device as? DimmableLight {
                                        if let percent = exec.params["brightness"]?.value as? Int {
                                            dimmableLight.setDim(percent: percent)
                                            execCommand.states["on"] = AnyCodable(dimmableLight.value)
                                        }
                                    }
                                } else if exec.command == "action.devices.commands.OnOff" {
                                    if let dimmableLight = device as? DimmableLight {
                                        if let on = exec.params["on"]?.value as? Bool {
                                            dimmableLight.switchLight(on: on)
                                            execCommand.states["on"] = AnyCodable(dimmableLight.value == 0)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    response.commands.append(execCommand)
                }
            }
        }
        return response
    }

    func getValueForPostBody(name: String, body: [String: String]?) -> String? {
        return body?[name]
    }
}
