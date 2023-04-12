//
//  Utils.swift
//  Onewheel-SwiftUI
//
//  Created by Adin Ackerman on 8/30/22.
//

import Foundation
import CryptoKit
import CoreBluetooth

struct CharacteristicWrapper: Identifiable {
    var characteristic: CBCharacteristic!
    let id: CBUUID
}

extension CBPeripheral: Identifiable {
    public var id: UUID {
        identifier
    }
}
