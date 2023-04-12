//
//  Battery.swift
//  Onewheel-SwiftUI
//
//  Created by Adin Ackerman on 12/6/22.
//

import Foundation

struct Battery {
    let voltage: CGFloat
    
    let cells: Int
    
    let minVoltage: CGFloat
    let maxVoltage: CGFloat
    
    init(voltage: CGFloat, cells: Int) {
        self.voltage = voltage
        self.cells = cells
        
        minVoltage = 3.0 * CGFloat(cells)
        maxVoltage = 4.2 * CGFloat(cells)
    }
    
    var soc: CGFloat {
        return (min(max(voltage, minVoltage), maxVoltage) - minVoltage) / (maxVoltage - minVoltage)
    }
}
