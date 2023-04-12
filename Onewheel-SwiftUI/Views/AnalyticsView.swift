//
//  AnalyticsView.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/13/22.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var vesc: VESC
    @EnvironmentObject var logger: Logger
    
    var body: some View {
        NavigationView {
            List {
                Section("Records") {
                    HStack {
                        Text("Top Speed")
                        Spacer()
                        Text("\(vesc.topSpeed)")
                    }
                    
                    HStack {
                        Text("Farthest Trip")
                        Spacer()
                    }
                }

                Section("Battery") {
                    NavigationLink {
                        SOCChart()
                            .environmentObject(logger)
                    } label: {
                        ProgressView(value: vesc.data.battery.soc, total: 1) {
                            HStack {
                                Image(systemName: "battery.100")
                                Text("\(Int(vesc.data.battery.soc * 100))%")
                            }
                        }
                    }

                    HStack {
                        Text("Batt Voltage")
                        Spacer()
                        Text("\(Float(vesc.data.inpVoltage)) V")
                    }
                }
                
                Section("Energy") {
                    NavigationLink {
                        EnergyChart()
                            .environmentObject(vesc)
                            .environmentObject(logger)
                    } label: {
                        HStack {
                            Text("Net Wh")
                            Spacer()
                            Text("\(vesc.data.wattHours - vesc.data.wattHoursCharged) Wh")
                        }
                    }
                }
                
                NavigationLink("Temps") {
                    TempsChart()
                        .environmentObject(vesc)
                        .environmentObject(logger)
                }
                
                Section("Balance") {
                    HStack {
                        Text("Footpads")
                        Spacer()
                        Image(systemName: vesc.data.adc1 > 3 ? "l.circle.fill" : "l.circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.primary, .blue)
                        Image(systemName: vesc.data.adc2 > 3 ? "r.circle.fill" : "r.circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.primary, .blue)
                    }
                }
                
//                Section("Balance") {
//                    HStack {
//                        Text("Operation State")
//                        Spacer()
//                        Text(String(reflecting: vesc.data.opState))
//                    }
//
//                    HStack {
//                        Text("Switch State")
//                        Spacer()
//                        Text(String(reflecting: vesc.data.switchState))
//                    }
//
//                    HStack {
//                        Text("Duty")
//                        Spacer()
//                        Text("\(Int(vesc.data.duty * 100))%")
//                    }
//
//                    HStack {
//                        Text("ADC1")
//                        Spacer()
//                        Text("\(CGFloat(vesc.data.adc1))")
//                    }
//
//                    HStack {
//                        Text("ADC2")
//                        Spacer()
//                        Text("\(CGFloat(vesc.data.adc2))")
//                    }
//
//                    HStack {
//                        Text("Pitch Angle")
//                        Spacer()
//                        Text("\(CGFloat(vesc.data.pitchAngle))°")
//                    }
//
//                    HStack {
//                        Text("Roll Angle")
//                        Spacer()
//                        Text("\(CGFloat(vesc.data.rollAngle))°")
//                    }
//                }
                
//                Group {
//                    Section("Ometers") {
//                        HStack {
//                            Text("Speed")
//                            Spacer()
//                            Text("\(vesc.data.speed) mph")
//                        }
//
//                        HStack {
//                            Text("Distance")
//                            Spacer()
//                            Text("\(Double(vesc.data.distance)) mi")
//                        }
//                    }
//
//                    Section("Temps") {
//                        HStack {
//                            Text("FET Temp")
//                            Spacer()
//                            Text("\(Float(vesc.data.tempMosfet))° C")
//                        }
//
//                        HStack {
//                            Text("Motor Temp")
//                            Spacer()
//                            Text("\(Float(vesc.data.tempMotor))° C")
//                        }
//                    }
//
//                    Section("Currents") {
//                        HStack {
//                            Text("Motor Current")
//                            Spacer()
//                            Text("\(vesc.data.avgMotorCurrent) A")
//                        }
//
//                        HStack {
//                            Text("Batt Current")
//                            Spacer()
//                            Text("\(vesc.data.avgInputCurrent) A")
//                        }
//                    }
//
//                    Section("Energy") {
//                        HStack {
//                            Text("Ah Consumed")
//                            Spacer()
//                            Text("\(vesc.data.ampHours) Ah")
//                        }
//
//                        HStack {
//                            Text("Ah Regenerated")
//                            Spacer()
//                            Text("\(vesc.data.ampHoursCharged) Ah")
//                        }
//
//                        HStack {
//                            Text("Wh Consumed")
//                            Spacer()
//                            Text("\(vesc.data.wattHours) Wh")
//                        }
//
//                        HStack {
//                            Text("Wh Regenerated")
//                            Spacer()
//                            Text("\(vesc.data.wattHoursCharged) Wh")
//                        }
//                    }
//
//                    HStack {
//                        Text("Fault")
//                        Spacer()
//                        Text(String(reflecting: vesc.data.error))
//                    }
//                }
            }
            .navigationTitle("Analytics")
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environmentObject(VESC())
            .environmentObject(Logger())
    }
}
