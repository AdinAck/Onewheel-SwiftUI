//
//  Speedometer.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/3/22.
//

import SwiftUI

struct Speedometer: View, Animatable {
    var speed: CGFloat
    
    var maxSpeed: CGFloat
    
    var animatableData: CGFloat {
        get { speed }
        set { speed = newValue }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .foregroundColor(.secondary)
            
            Circle()
                .trim(from: 0, to: speed / maxSpeed)
                .stroke(style: StrokeStyle(lineWidth: 16))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(90))
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(Int(speed))")
                            .font(.system(size: min(geometry.size.width, geometry.size.height) / 2))
                        Spacer()
                    }
                    Text("MPH")
                    Spacer()
                }
            }
            
        }
    }
}

struct Speedometer_Previews: PreviewProvider {
    static var previews: some View {
        Speedometer(speed: 20, maxSpeed: 30)
    }
}
