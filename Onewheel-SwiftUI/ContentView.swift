//
//  ContentView.swift
//  Shared
//
//  Created by Adin Ackerman on 8/30/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vesc: VESC
    @StateObject var logger: Logger = Logger()
    
    @State var searching: Bool = true
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    // instruments
                    let damping = abs(vesc.data.current) * 5 + CGFloat(1)
                    
                    BatteryBar(percentage: vesc.data.battery.soc)
                        .animation(.spring(response: damping, dampingFraction: damping), value: vesc.data.battery.soc)
                        .animation(.spring(), value: damping)
                        .padding()
                    
                    // warnings
                    switch vesc.data.opState {
                    case .RUNNING_TILTBACK_DUTY: // pushback
                        Label("Pushback", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                    case .RUNNING_TILTBACK_HIGH_VOLTAGE: // overcharging
                        Label("Overcharging", systemImage: "battery.100.bolt")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.yellow, .blue)
                    case .RUNNING_TILTBACK_LOW_VOLTAGE: // battery dead
                        Label("Low Battery", systemImage: "battery.0.fill")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                    
                    if vesc.data.switchState == .HALF && vesc.data.speed > 10 {
                        Label("One foot at high speed", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    // instruments
                    let active = (1...4).contains(vesc.data.opState.rawValue)
                    
                    ZStack {
                        Speedometer(speed: vesc.data.speed, maxSpeed: vesc.topSpeed)
                            .animation(.spring(), value: vesc.data.speed)
                            .padding(64)
                            .scaleEffect(active ? 1 : 0.7)
                            .opacity(active ? 1 : 0.5)
                            .animation(.spring(), value: active)
                        
                        DutyMeter(duty: vesc.data.duty)
                            .animation(.spring(), value: vesc.data.duty)
                            .scaleEffect(active ? 1 : 0.7, anchor: UnitPoint(x: 0, y: 0.5))
                            .opacity(active ? 1 : 0.5)
                            .padding(8)
                        
                        PowerMeter(current: vesc.data.current)
                            .animation(.spring(), value: vesc.data.current)
                            .scaleEffect(active ? 1 : 0.7, anchor: UnitPoint(x: 1, y: 0.5))
                            .opacity(active ? 1 : 0.5)
                            .padding(8)
                    }
                    .layoutPriority(1)
                    
                    
                    HStack {
                        Spacer()
                        Text("**Duty:** \(Int(vesc.data.duty * 100))%")
                            .padding(.horizontal)
                            .padding(.bottom)
                        Text("**Current:** \(Int(vesc.data.current)) A")
                            .padding(.horizontal)
                            .padding(.bottom)
                        Spacer()
                    }
                    
                    HStack {
                        Temps(temp: max(vesc.data.fetTemp, vesc.data.motorTemp))
                            .padding()
                        
                        Distance()
                            .padding()
                            .environmentObject(vesc)
                    }
                }
                .animation(.default, value: vesc.data.opState)
                .animation(.default, value: vesc.data.switchState)
                .navigationTitle("Dashboard")
                .grayscale(vesc.loaded ? 0 : 0.8)
            }
            .tabItem {
                Label("Dashboard", systemImage: "speedometer")
            }
            
            AnalyticsView()
                .environmentObject(vesc)
                .environmentObject(logger)
                .tabItem {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }
            
            SettingsView()
                .environmentObject(vesc)
                .navigationTitle("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            DispatchQueue.global().async {
                while true {
                    if vesc.loaded {
                        // i think this is not threadsafe
                        
                        vesc.getValues(type: .COMM_GET_VALUES)
                        Thread.sleep(forTimeInterval: 0.1)
                        
                        vesc.getValues(type: .COMM_GET_DECODED_BALANCE)
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                }
            }
            
            DispatchQueue.global().async {
                while true {
                    Thread.sleep(forTimeInterval: 60)
                    
                    if vesc.loaded {
                        DispatchQueue.main.async {
                            let distance = vesc.data.distance
                            logger.updateHistory(history: &logger.socHistory, distance: distance, value: vesc.data.battery.soc)
                            logger.updateHistory(history: &logger.energyHistory, distance: distance, value: Double(vesc.data.wattHours - vesc.data.wattHoursCharged))
                            logger.updateHistory(history: &logger.fetTempHistory, distance: distance, value: max(vesc.data.fetTemp, vesc.data.motorTemp)) // temporary
                            logger.updateHistory(history: &logger.motorTempHistory, distance: distance, value: vesc.data.motorTemp)
                        }
                    }
                }
            }
        }
        .onChange(of: vesc.loaded) { newValue in
            searching = !vesc.loaded && vesc.favorite == ""
        }
        .onChange(of: vesc.favorite) { newValue in
            searching = !vesc.loaded && vesc.favorite == ""
        }
        .onChange(of: searching) { newValue in
            if vesc.loaded {
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: 3)
                    DispatchQueue.main.async {
                        vesc.data.startingSOC = vesc.data.battery.soc
                        vesc.data.startingDistance = vesc.data.distance
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $searching) {
            SelectDeviceView()
                .environmentObject(vesc)
        }
        .onChange(of: vesc.peripheral) { newValue in
            if let _ = vesc.peripheral {
                vesc.connect()
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
