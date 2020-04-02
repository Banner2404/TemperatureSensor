//
//  AWSShadow.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/2/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import Foundation

struct AWSShadowDocument: Decodable {

    let state: AWSShadowState
}

struct AWSShadowUpdate: Decodable {

    let current: AWSShadowDocument
}

struct AWSShadowState: Decodable {

    let reported: Shadow
}

struct Shadow: Decodable {

    let temperature: Double
}
