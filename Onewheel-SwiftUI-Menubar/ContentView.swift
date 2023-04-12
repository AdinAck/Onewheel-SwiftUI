//
//  ContentView.swift
//  Onewheel-SwiftUI-Menubar
//
//  Created by Adin Ackerman on 12/6/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vesc: VESC
    
    var body: some View {
        if vesc.loaded {
            List {
                ProgressView(value: vesc.data.battery.percentage, total: 1) {
                    HStack {
                        Image(systemName: "battery.100")
                        Text("\(Int(vesc.data.battery.percentage * 100))%")
                    }
                }
                
                HStack {
                    Text("Batt Voltage")
                    Spacer()
                    Text("\(Float(vesc.data.inpVoltage)) V")
                }
            }

        } else {
            SelectDeviceView()
                .environmentObject(vesc)
                .onChange(of: vesc.peripheral) { newValue in
                    if let _ = vesc.peripheral {
                        vesc.connect()
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vesc: VESC())
    }
}
