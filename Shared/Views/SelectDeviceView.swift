//
//  SelectDeviceView.swift
//  Onewheel-SwiftUI
//
//  Created by Adin Ackerman on 12/2/22.
//

import SwiftUI

struct SelectDeviceView: View {
    @EnvironmentObject var vesc: VESC
    
    var body: some View {
            List(selection: $vesc.peripheral) {
                if vesc.discovered.count > 0 {
                    ForEach(vesc.discovered, id: \.id) { device in
                        HStack {
                            Text(device.name ?? "UNKNOWN")
                                .bold()
                            
                            Spacer()
                            
                            Image(systemName: device.identifier.uuidString == vesc.favorite ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    if device.identifier.uuidString == vesc.favorite {
                                        vesc.favorite = ""
                                    } else {
                                        vesc.favorite = device.identifier.uuidString
                                    }
                                }
                        }
                        .tag(device)
                    }
                } else {
                    HStack {
                        Text("Scanning...")
                            .italic()
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                }
                
                #if os(macOS)
                HStack {
                    Button("Refresh") {
                        withAnimation {
                            vesc.discovered = []
                        }
                    }
                    
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                }
                #endif
            }
            .refreshable {
                vesc.startScanning()
            }
    }
}

//struct SelectDeviceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectDeviceView()
//    }
//}
