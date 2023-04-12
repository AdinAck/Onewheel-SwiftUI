//
//  EnergyChart.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/14/22.
//

import SwiftUI
import Charts

struct EnergyChart: View {
    @EnvironmentObject var vesc: VESC
    @EnvironmentObject var logger: Logger
    
    var body: some View {
        let curColor: Color = .green
        let curGradient = LinearGradient(
            gradient: Gradient (
                colors: [
                    curColor.opacity(0.5),
                    curColor.opacity(0.2),
                    curColor.opacity(0.05),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        
        List {
            Chart {
                ForEach(logger.energyHistory) { item in
                    LineMark(x: .value("Distance", item.distance), y: .value("Energy", item.value))
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        .foregroundStyle(curColor)
                    
                    AreaMark(x: .value("Distance", item.distance), y: .value("Energy", item.value))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(curGradient)
                }
            }
            .chartXAxisLabel("Distance (miles)")
            .chartYAxisLabel("Energy Consumed (Wh)")
            .frame(height: 300)
            
            HStack {
                Text("Ah Consumed")
                Spacer()
                Text("\(vesc.data.ampHours) Ah")
            }
            
            HStack {
                Text("Ah Regenerated")
                Spacer()
                Text("\(vesc.data.ampHoursCharged) Ah")
            }
            
            HStack {
                Text("Wh Consumed")
                Spacer()
                Text("\(vesc.data.wattHours) Wh")
            }
            
            HStack {
                Text("Wh Regenerated")
                Spacer()
                Text("\(vesc.data.wattHoursCharged) Wh")
            }
        }
    }
}

struct EnergyChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyChart()
            .environmentObject(VESC())
            .environmentObject(Logger())
    }
}
