//
//  HistoryEntry.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/3/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import Foundation
import AWSDynamoDB

class HistoryEntry: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    @objc var id: NSNumber?
    @objc var timestamp: NSNumber?
    @objc var temperature: NSNumber?

    var timestampValue: Int {
        return timestamp?.intValue ?? 0
    }
    var temperatureValue: Float {
        return temperature?.floatValue ?? 0
    }

    static func dynamoDBTableName() -> String {
        return "temperature_data"
    }

    static func hashKeyAttribute() -> String {
        return "id"
    }
}
