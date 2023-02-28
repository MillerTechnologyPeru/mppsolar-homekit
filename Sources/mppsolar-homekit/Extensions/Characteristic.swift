//
//  Characteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 2/28/23.
//

import Foundation
import HAP
import MPPSolar

extension FlagStatus {
    
    func homeKitCharacteristic() -> GenericCharacteristic<Bool> {
        GenericCharacteristic<Bool>(
            type: .solarFlag(self),
            value: false,
            permissions: [.read, .write, .events],
            description: self.description,
            format: .bool,
            unit: .none
        )
    }
}
