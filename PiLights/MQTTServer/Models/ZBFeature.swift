//
//  ZBFeature.swift
//  PiLights
//
//  Created by Philippe Weidmann on 22.02.22.
//  Copyright © 2022 Philippe Weidmann. All rights reserved.
//

import Foundation
import HAP

class ZBFeatureDecoderHelper {
    static func getFeaturesFromContainer(_ container: UnkeyedDecodingContainer) throws -> [Feature] {
        var container = container
        var tmpContainer = container
        var features = [Feature]()

        while !container.isAtEnd {
            let typeContainer = try container.nestedContainer(keyedBy: EmptyFeature.CodingKeys.self)
            let type = try typeContainer.decode(FeatureType.self, forKey: EmptyFeature.CodingKeys.type)

            switch type {
            case .binary:
                features.append(try tmpContainer.decode(BinaryFeature.self))
            case .numeric:
                let numericFeature = try tmpContainer.decode(NumericFeature.self)
                // HomeKit only supports value >= 50 & <= 400
                if numericFeature.name == .colorTemp {
                    numericFeature.valueMax = min(400, numericFeature.valueMax)
                    numericFeature.valueMin = max(50, numericFeature.valueMin)
                }
                features.append(numericFeature)
            case .light:
                features.append(try tmpContainer.decode(LightFeature.self))
            default:
                _ = try tmpContainer.decode(EmptyFeature.self)
                logger.info("Type not handled \(type.rawValue)")
            }
        }
        return features
    }
}

enum FeatureType: String, Decodable {
    case light
    case binary
    case numeric
    case `enum`
    case text
    case composite
    case unknown

    public init(from decoder: Decoder) throws {
        self = FeatureType(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .unknown
    }
}

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}

enum FeatureName: String, Decodable {
    static let featureNameToCharacteristicType: [FeatureName: CharacteristicType] = [.state: .powerState, .brightness: .brightness, .colorTemp: .colorTemperature]
    
    case state
    case brightness
    case colorTemp = "color_temp"
    case unknown

    public init(from decoder: Decoder) throws {
        self = FeatureName(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .unknown
    }
}

protocol Feature: Decodable {
    var type: FeatureType { get }
}

protocol NamedFeature {
    var name: FeatureName { get }
}

class EmptyFeature: Feature {
    let type: FeatureType

    enum CodingKeys: String, CodingKey {
        case type
    }
}

class BinaryFeature: Feature, NamedFeature {
    let type: FeatureType
    let name: FeatureName
    let property: String
    let valueOn: String
    let valueOff: String
    let access: Int
}

class NumericFeature: Feature, NamedFeature {
    let type: FeatureType
    let name: FeatureName
    let property: String
    var valueMin: Int
    var valueMax: Int
    let access: Int
}

class LightFeature: Feature {
    let type: FeatureType
    let features: [Feature]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(FeatureType.self, forKey: .type)
        features = try ZBFeatureDecoderHelper.getFeaturesFromContainer(try container.nestedUnkeyedContainer(forKey: .features))
    }

    enum CodingKeys: String, CodingKey {
        case type
        case features
    }
}
