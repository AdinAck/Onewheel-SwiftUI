//
//  DutyMeter.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/9/22.
//

import SwiftUI

struct DutyMeter: View, Animatable {
    var duty: CGFloat
    
    var animatableData: CGFloat {
        get { duty }
        set { duty = newValue }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.6, to: 0.9)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0.6, to: 0.6 + max(0, duty) * 0.3)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.purple)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0.6 - (-1 - min(0, duty)) * 0.3, to: 0.9)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .foregroundColor(.purple)
                .rotationEffect(.degrees(-90))
        }
    }
}

struct DutyMeter_Previews: PreviewProvider {
    static var previews: some View {
        DutyMeter(duty: 0.8)
    }
}
