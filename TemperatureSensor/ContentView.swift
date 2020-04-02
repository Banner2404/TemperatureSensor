//
//  ContentView.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/2/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var temperatureManager: TemperatureManager

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(String(describing: temperatureManager.status).capitalized)
            }.padding()
            Spacer()
            HStack(alignment: .firstTextBaseline) {
                Text("\(temperatureManager.temperature, specifier: "%.1f")")
                    .font(.system(size: 80))
                Text("°C")
                    .font(.system(size: 40))
            }
            Spacer()

        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(TemperatureManager())
    }
}
