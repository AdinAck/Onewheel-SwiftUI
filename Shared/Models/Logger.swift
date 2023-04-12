//
//  Logger.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/14/22.
//

import Foundation

struct ValueAtDistance: Identifiable {
    let distance: Double
    let value: Double
    
    var id: Double {
        distance
    }
}

class Logger: ObservableObject {
    @Published var socHistory: [ValueAtDistance] = []
    @Published var energyHistory: [ValueAtDistance] = []
    @Published var fetTempHistory: [ValueAtDistance] = []
    @Published var motorTempHistory: [ValueAtDistance] = []
    
    func updateHistory(history: inout [ValueAtDistance], distance: Double, value: Double) {
        // overwrite duplicate entry
        if history.contains(where: { point in point.distance == distance }) {
            let _ = history.popLast()
        }
        
        history.append(ValueAtDistance(distance: distance, value: value))
    }
}
