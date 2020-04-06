//
//  MainViewController.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/5/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import UIKit
import Combine
import Charts

class MainViewController: UIViewController {

    private let intervals: [HistoryManager.Interval] = [.day, .week]
    private var selectedInterval: HistoryManager.Interval {
        return intervals[segmentedControl.selectedSegmentIndex]
    }
    private var cancellableBag = Set<AnyCancellable>()
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var historyActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        TemperatureManager.shared.$temperature
            .map { self.numberFormatter.string(from: NSNumber(value: $0)) }
            .assign(to: \.text, on: temperatureLabel)
            .store(in: &cancellableBag)

        TemperatureManager.shared.$status
            .map { String(describing: $0).capitalized }
            .assign(to: \.text, on: connectionLabel)
            .store(in: &cancellableBag)

        HistoryManager.shared.$historyEntries
            .map { self.chartData(from: $0) }
            .assign(to: \.data, on: chartView)
            .store(in: &cancellableBag)

        HistoryManager.shared.$isLoading
            .map { !$0 }
            .assign(to: \.isHidden, on: historyActivityIndicator)
            .store(in: &cancellableBag)

        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.legend.enabled = false
        updateScale()
    }

    func chartData(from entries: [HistoryEntry]) -> LineChartData {
        let chartEntries = entries.map { entry in
            ChartDataEntry(x: Double(entry.timestampValue), y: Double(entry.temperatureValue))
        }
        let dataSet = LineChartDataSet(entries: chartEntries)
        dataSet.fillColor = .green
        dataSet.colors = [.green]
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.highlightEnabled = false
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false

        return LineChartData(dataSet: dataSet)
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        HistoryManager.shared.selectedInterval = selectedInterval
        updateScale()
    }

    func updateScale() {
        chartView.xAxis.axisMinimum = selectedInterval.startDate
        chartView.xAxis.valueFormatter = selectedInterval.formatter
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
