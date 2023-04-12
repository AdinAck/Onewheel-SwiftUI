//
//  Temps.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/5/22.
//

import SwiftUI

struct Temps: View {
    let temp: CGFloat
    
    private let maxTemp: CGFloat = 80
    
    private var color: Color {
        Color(hue: 0.4 * (1 - min(temp / maxTemp, CGFloat(1))), saturation: 1, brightness: 1)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "thermometer.low")
            
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Text("\(Int(temp))° C")
                            .font(.caption)
                        Spacer()
                    }
                    
                    ZStack {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.secondary)
                        Rectangle()
                            .frame(width: geometry.size.width * temp / maxTemp, height: 2)
                            .foregroundColor(color)
                            .offset(x: -geometry.size.width * (0.5 - temp / maxTemp / 2))
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(width: 50)
        }
    }
}

struct Temps_Previews: PreviewProvider {
    static var previews: some View {
        Temps(temp: 23)
    }
}
