//
//  MQTTDefinition.swift
//  PiLights
//
//  Created by Philippe Weidmann on 22.02.22.
//  Copyright © 2022 Philippe Weidmann. All rights reserved.
//

import Foundation

class ZBDefinition: Decodable {
    let model: String
    let vendor: String
    let description: String
    let exposes: [Feature]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        model = try container.decode(String.self, forKey: .model)
        vendor = try container.decode(String.self, forKey: .vendor)
        description = try container.decode(String.self, forKey: .description)
        exposes = try ZBFeatureDecoderHelper.getFeaturesFromContainer(try container.nestedUnkeyedContainer(forKey: .exposes))
    }

    enum CodingKeys: String, CodingKey {
        case model
        case vendor
        case description
        case exposes
    }
}
