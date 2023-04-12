//
//  TempsChart.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/14/22.
//

import SwiftUI
import Charts

struct TempsChart: View {
    @EnvironmentObject var vesc: VESC
    @EnvironmentObject var logger: Logger
    
    var body: some View {
        let color1: Color = .yellow
        let gradient1 = LinearGradient(
            gradient: Gradient (
                colors: [
                    color1.opacity(0.5),
                    color1.opacity(0.2),
                    color1.opacity(0.05),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        
//        let color2: Color = .orange
//        let gradient2 = LinearGradient(
//            gradient: Gradient (
//                colors: [
//                    color2.opacity(0.5),
//                    color2.opacity(0.2),
//                    color2.opacity(0.05),
//                ]
//            ),
//            startPoint: .top,
//            endPoint: .bottom
//        )
        
        List {
            Chart {
                ForEach(logger.fetTempHistory) { item in
                    LineMark(x: .value("Distance", item.distance), y: .value("Temp", item.value))
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        .foregroundStyle(color1)
                    
                    AreaMark(x: .value("Distance", item.distance), y: .value("Temp", item.value), stacking: .unstacked)
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(gradient1)
                }
                
//                ForEach(logger.motorTempHistory) { item in
//                    LineMark(x: .value("Distance", item.distance), y: .value("Temp", item.value))
//                        .interpolationMethod(.catmullRom)
//                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
//                        .foregroundStyle(color2)
//
//                    AreaMark(x: .value("Distance", item.distance), y: .value("Temp", item.value), stacking: .unstacked)
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(gradient2)
//                }
            }
            .chartXAxisLabel("Distance (miles)")
            .chartYAxisLabel("Temperature (°C)")
            .frame(height: 300)
            
            HStack {
                Text("FET Temp")
                Spacer()
                Text("\(Float(vesc.data.tempMosfet)) °C")
            }
            
            HStack {
                Text("Motor Temp")
                Spacer()
                Text("\(Float(vesc.data.tempMotor)) °C")
            }
        }
    }
}

struct TempsChart_Previews: PreviewProvider {
    static var previews: some View {
        TempsChart()
            .environmentObject(VESC())
            .environmentObject(Logger())
    }
}
