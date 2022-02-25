//
//  ZBLight.swift
//  PiLights
//
//  Created by Philippe Weidmann on 22.02.22.
//  Copyright © 2022 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

protocol TypeErasedcCharacteristic {}

extension GenericCharacteristic: TypeErasedcCharacteristic {}

class ZBAccessory: Accessory {
    private var zbDevice: ZBDevice
    private var exposedFeatures = [FeatureName: Feature]()
    private var exposedCharacteristics = [FeatureName: TypeErasedcCharacteristic]()

    init?(zbDevice: ZBDevice) {
        self.zbDevice = zbDevice
        var type: AccessoryType = .other
        var service: Service?
        if let definition = zbDevice.definition {
            for feature in definition.exposes {
                if let lightFeature = feature as? LightFeature {
                    type = .lightbulb
                    var characteristics = [AnyCharacteristic]()
                    for feature in lightFeature.features {
                        if let binaryFeature = feature as? BinaryFeature,
                           let characteristicType = FeatureName.featureNameToCharacteristicType[binaryFeature.name] {
                            let characteristic = GenericCharacteristic<Bool>(type: characteristicType, value: true)
                            characteristics.append(AnyCharacteristic(characteristic))
                            exposedFeatures[binaryFeature.name] = binaryFeature
                            exposedCharacteristics[binaryFeature.name] = characteristic
                        } else if let numericFeature = feature as? NumericFeature,
                                  let characteristicType = FeatureName.featureNameToCharacteristicType[numericFeature.name] {
                            let characteristic = GenericCharacteristic<Int>(type: characteristicType,
                                                                            value: numericFeature.valueMax,
                                                                            maxValue: Double(numericFeature.valueMax),
                                                                            minValue: Double(numericFeature.valueMin))
                            characteristics.append(AnyCharacteristic(characteristic))
                            exposedFeatures[numericFeature.name] = numericFeature
                            exposedCharacteristics[numericFeature.name] = characteristic
                        }
                    }

                    service = Service.Lightbulb(characteristics: characteristics)
                }
            }
        }
        if let service = service {
            super.init(info: .init(name: zbDevice.friendlyName, serialNumber: zbDevice.ieeeAddress), type: type, services: [service])
        } else {
            return nil
        }
    }

    func updateCharacteristics(with updatedValues: [String: AnyObject]) {
        for (key, value) in updatedValues {
            if let featureName = FeatureName(rawValue: key),
               let characteristic = exposedCharacteristics[featureName] {
                if let intCharacteristic = characteristic as? GenericCharacteristic<Int>,
                   let intValue = value as? Int {
                    intCharacteristic.value = intValue
                } else if let binaryCharacteristic = characteristic as? GenericCharacteristic<Bool>,
                          let stringValue = value as? String,
                          let binaryFeature = exposedFeatures[featureName] as? BinaryFeature {
                    if stringValue == binaryFeature.valueOn {
                        binaryCharacteristic.value = true
                    } else if stringValue == binaryFeature.valueOff {
                        binaryCharacteristic.value = false
                    }
                }
            }
        }
    }

    override func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, didChangeValue newValue: T?) where T: CharacteristicValueType {
        if let featureName = FeatureName.featureNameToCharacteristicType.key(forValue: characteristic.type),
           let feature = exposedFeatures[featureName] {
            if let feature = feature as? BinaryFeature,
               let newValue = newValue as? Bool {
                MQTTServer.instance.setBinaryFeature(feature, value: newValue, for: zbDevice)
            } else if let feature = feature as? NumericFeature,
                      let newValue = newValue as? Int {
                MQTTServer.instance.setNumericFeature(feature, value: newValue, for: zbDevice)
            }
        }
        super.characteristic(characteristic, ofService: service, didChangeValue: newValue)
    }
}
