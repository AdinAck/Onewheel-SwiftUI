//
//  Packages.swift
//  Onewheel-SwiftUI
//
//  Created by Adin Ackerman on 12/2/22.
//

import Foundation
import SwiftUI

struct DataPackage {
    // standard
    var avgMotorCurrent:   Float32       = 0
    var avgInputCurrent:   Float32       = 0
    var dutyCycleNow:      Float16       = 0
    var rpm:               Float32       = 0
    var inpVoltage:        Float16       = 50
    var ampHours:          Float32       = 0
    var ampHoursCharged:   Float32       = 0
    var wattHours:         Float32       = 0
    var wattHoursCharged:  Float32       = 0
    var tachometer:        Int32         = 0
    var tachometerAbs:     Int32         = 0
    var tempMosfet:        Float16       = 0
    var tempMotor:         Float16       = 0
    var pidPos:            Float32       = 0
    var id:                UInt8         = 0
    var error:             MCFaultCode = .FAULT_CODE_NONE
    
    // balance
    var pitchAngle:       Float32       = 0
    var rollAngle:        Float32       = 0
    var opState:          BalanceState  = .STARTUP
    var switchState:      SwitchState   = .OFF
    var adc1:             Float32       = 0
    var adc2:             Float32       = 0
    
    var startingSOC:      CGFloat?
    var startingDistance: CGFloat?
    
    // requires app restart to update
    @AppStorage("batt-cells-series") var cells: Int = 4
    
    var battery: Battery {
        Battery(voltage: CGFloat(inpVoltage), cells: cells)
    }

    var speed: CGFloat {
        abs(CGFloat(rpm / 15 * 60 * (3.14 * 0.285) / 1609.34))
    }
    
    var current: CGFloat {
        CGFloat(avgInputCurrent)
    }
    
    var distance: CGFloat {
        CGFloat(tachometerAbs) / 30 * 0.285 / 1609.34
    }
    
    var fetTemp: CGFloat {
        CGFloat(tempMosfet)
    }
    
    var motorTemp: CGFloat {
        CGFloat(tempMotor)
    }
    
    var duty: CGFloat {
        CGFloat(dutyCycleNow)
    }
}

struct FWversionPackage {
    var major: UInt8 = 0
    var minor: UInt8 = 0
}
