//
//  HistoryManager.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/3/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import Foundation
import AWSDynamoDB

class HistoryManager: ObservableObject {

    @Published var historyEntries: [HistoryEntry] = []
    lazy var objectMapper = AWSDynamoDBObjectMapper.default()

    init() {
        initConfiguration()
    }

    func loadData() {
        let query = AWSDynamoDBQueryExpression()
        query.keyConditionExpression = "#id = :id"
        query.expressionAttributeNames = [
            "#id": "id"
        ]
        query.expressionAttributeValues = [
            ":id": 1
        ]

        objectMapper.query(HistoryEntry.self, expression: query) { (output, error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.historyEntries = output?.items.compactMap { $0 as? HistoryEntry } ?? []
                print("History:", self.historyEntries)
            }
        }
    }

    func initConfiguration() {
        let credentials = AWSStaticCredentialsProvider(accessKey: "AKIAIAES6VRJGDYJS7BA", secretKey: "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")
        let config = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentials)
        AWSServiceManager.default()?.defaultServiceConfiguration = config
    }
}
