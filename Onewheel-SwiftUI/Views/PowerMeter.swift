//
//  PowerMeter.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/3/22.
//

import SwiftUI

struct PowerMeter: View, Animatable {
    var current: CGFloat
    
    private let maxCurrent: CGFloat = 30
    
    var animatableData: CGFloat {
        get { current }
        set { current = newValue }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.6, to: 0.9)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(90))
            
            Circle()
                .trim(from: 0.6 + (1 - max(0, current / maxCurrent)) * 0.3, to: 0.9)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(90))
            
            Circle()
                .trim(from: 0.6, to: 0.6 - min(0, current / maxCurrent) * 0.3)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.green)
                .rotationEffect(.degrees(90))
        }
    }
}

struct PowerMeter_Previews: PreviewProvider {
    static var previews: some View {
        PowerMeter(current: 20)
    }
}
