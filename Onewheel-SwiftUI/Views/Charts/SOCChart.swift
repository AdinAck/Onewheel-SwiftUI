//
//  SOCChart.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/14/22.
//

import SwiftUI
import Charts

struct SOCChart: View {
    @EnvironmentObject var logger: Logger
    
    var body: some View {
        let curColor: Color = .blue
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
        
        Chart {
            ForEach(logger.socHistory) { item in
                LineMark(x: .value("Distance", item.distance), y: .value("Battery", item.value))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                
                AreaMark(x: .value("Distance", item.distance), y: .value("Battery", item.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(curGradient)
            }
        }
        .chartXAxisLabel("Distance (miles)")
        .chartYAxisLabel("Battery SOC (%)")
    }
}

struct SOCChart_Previews: PreviewProvider {
    static var previews: some View {
        SOCChart()
            .environmentObject(Logger())
    }
}
