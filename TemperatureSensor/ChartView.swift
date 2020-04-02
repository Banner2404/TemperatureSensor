//
//  ChartView.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/2/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import SwiftUI
import Charts

struct ChartView: UIViewRepresentable {

    func makeUIView(context: Context) -> LineChartView {
        let view = LineChartView()
        let entry1 = ChartDataEntry(x: 1, y: 25.4)
        let entry2 = ChartDataEntry(x: 2, y: 20.4)
        let entry3 = ChartDataEntry(x: 3, y: 21.4)
        let entry4 = ChartDataEntry(x: 4, y: 21.5)
        let entry5 = ChartDataEntry(x: 5, y: 21.4)

        let dataSet = LineChartDataSet(entries: [entry1, entry2, entry3, entry4, entry5])
        dataSet.fillColor = .green
        dataSet.colors = [.green]
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.highlightEnabled = false
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false
        view.data = LineChartData(dataSet: dataSet)
        view.xAxis.drawGridLinesEnabled = false
        view.xAxis.drawLabelsEnabled = false
        view.leftAxis.axisMinimum = 0
        view.rightAxis.drawGridLinesEnabled = false
        view.rightAxis.drawLabelsEnabled = false
        view.legend.enabled = false
        return view
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {

    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
