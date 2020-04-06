//
//  HistoryManager.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/3/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import Foundation
import AWSDynamoDB
import Charts

class HistoryManager: ObservableObject {

    static let shared = HistoryManager()
    var selectedInterval = Interval.day {
        didSet {
            historyEntries = []
            loadData()
        }
    }
    @Published var historyEntries: [HistoryEntry] = []
    @Published var isLoading = false
    lazy var objectMapper = AWSDynamoDBObjectMapper.default()

    private init() {
        initConfiguration()
    }

    func loadData() {
        let query = AWSDynamoDBQueryExpression()
        query.keyConditionExpression = "#id = :id and #timestamp > :timestamp"
        query.expressionAttributeNames = [
            "#id": "id",
            "#timestamp": "timestamp"
        ]
        let startDate = selectedInterval.startDate
        query.expressionAttributeValues = [
            ":id": 1,
            ":timestamp": startDate
        ]
        isLoading = true
        objectMapper.query(HistoryEntry.self, expression: query) { (output, error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.isLoading = false
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

    enum Interval {
        case day
        case week

        var startDate: TimeInterval {
            return Date().addingTimeInterval(-timeInterval).timeIntervalSince1970
        }

        var timeInterval: TimeInterval {
            switch self {
            case .day:
                return 60 * 60 * 24
            case .week:
                return 60 * 60 * 24 * 7
            }
        }

        var formatter: ValueFormatter {
            switch self {
            case .day:
                return ValueFormatter(format: "HH")
            case .week:
                return ValueFormatter(format: "E")
            }
        }
    }
}

class ValueFormatter: IAxisValueFormatter {

    let dateFormatter: DateFormatter

    init(format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        self.dateFormatter = formatter
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

