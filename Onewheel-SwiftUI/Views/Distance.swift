//
//  Distance.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/8/22.
//

import SwiftUI

struct Distance: View {
    @EnvironmentObject var vesc: VESC
    
    private var socDelta: CGFloat? {
        let soc = vesc.data.battery.soc
        if let start = vesc.data.startingSOC {
            return start - soc
        }
        
        return nil
    }
    
    private var distDelta: CGFloat? {
        let distance = vesc.data.distance
        if let start = vesc.data.startingDistance {
            return distance - start
        }
        
        return nil
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("**Trip:**")
                Text("**Remaining:**")
            }
            
            VStack(alignment: .trailing) {
                Text("\(String(format: "%0.1f", vesc.data.distance - (vesc.data.startingDistance ?? 0))) mi")

                let soc = vesc.data.battery.soc

                if socDelta != nil && distDelta != nil && socDelta != 0 {
                    let estimate = socDelta! > 0 ? distDelta! * (soc / socDelta!) : distDelta! * ((1 - soc) / -socDelta!)
                    Text("\(String(format: "%0.1f", estimate)) mi")
                } else {
                    Text("- mi")
                }
            }
        }
    }
}

struct Distance_Previews: PreviewProvider {
    static var previews: some View {
        Distance()
            .environmentObject(VESC())
    }
}
