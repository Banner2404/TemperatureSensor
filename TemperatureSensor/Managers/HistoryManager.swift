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

    static let shared = HistoryManager()
    @Published var historyEntries: [HistoryEntry] = []
    lazy var objectMapper = AWSDynamoDBObjectMapper.default()

    private init() {
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
        guard let credentialsUrl = Bundle.main.url(forResource: "credentials", withExtension: "json") else { return }
        guard let credentialsData = try? Data(contentsOf: credentialsUrl), let json = try? JSONSerialization.jsonObject(with: credentialsData, options: []) as? [String: String] else { return }
        guard let accessKey = json["access_key"], let secretKey = json["secret_key"] else { return }
        let credentials = AWSStaticCredentialsProvider(accessKey: accessKey , secretKey: secretKey)
        let config = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentials)
        AWSServiceManager.default()?.defaultServiceConfiguration = config
    }
}
