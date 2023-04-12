//
//  BatteryBar.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/3/22.
//

import SwiftUI

struct BatteryBar: View, Animatable {
    var percentage: CGFloat
    
    var animatableData: CGFloat {
        get { percentage }
        set { percentage = newValue }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: 64)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                Rectangle()
                    .frame(width: geometry.size.width * percentage)
                    .foregroundColor(.blue)
            }
            .mask(
                RoundedRectangle(cornerRadius: 16)
                    .frame(height: 64)
            )
            
            HStack {
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .bold()
                    .font(.title)
                    .padding()
            }
        }
    }
}

struct BatteryBar_Previews: PreviewProvider {
    static var previews: some View {
        BatteryBar(percentage: 0.83)
    }
}
