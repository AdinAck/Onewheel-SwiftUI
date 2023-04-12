//
//  SettingsView.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/2/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vesc: VESC
    
    var body: some View {
        NavigationView {
            List {
                Section("Configs") {
                    HStack {
                        Text("Favorite")
                        Spacer()
                        Image(systemName: vesc.peripheral?.identifier.uuidString == vesc.favorite ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                if vesc.peripheral?.identifier.uuidString == vesc.favorite {
                                    vesc.favorite = ""
                                } else {
                                    vesc.favorite = vesc.peripheral?.identifier.uuidString ?? ""
                                }
                            }
                    }
                }
                
                Section("Battery") {
//                    Picker("Cells (series)", selection: $vesc.data.cells) {
//                        ForEach(4..<25) { num in
//                            Text("\(num)")
//                                .tag(num)
//                        }
//                    }
                    DataEntryView(data: Binding(get: {
                        String(vesc.data.cells)
                    }, set: { string, _ in
                        if let num = Int(string) {
                            vesc.data.cells = num
                        }
                    }))
                }
                
                Section("Trip") {
                    Button("Reset Trip") {
                        vesc.data.startingSOC = vesc.data.battery.soc
                        vesc.data.startingDistance = vesc.data.distance
                    }
                }
                
                Section("Device") {
                    Button("Disconnect") {
                        vesc.disconnect(manual: true)
                    }
                }
                
                Section("User Data") {
                    Button("Erase User Data") {
                        vesc.disconnect(manual: true)
                        
                        DispatchQueue.main.async {
                            // there should be a better way to do this
                            vesc.favorite = ""
                            vesc.topSpeed = 0
                        }
                    }
                    .tint(.red)
                }
                
    #if os(macOS)
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
    #endif
            }
            .navigationTitle("Settings")
        }
    }
}

struct VESCDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(VESC())
    }
}
