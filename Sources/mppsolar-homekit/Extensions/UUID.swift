//
//  UUID.swift
//  
//
//  Created by Alsey Coleman Miller on 2/27/23.
//

import Foundation
import HAP
import MPPSolar

public extension UUID {
    
    static func solarHomeKit(_ index: UInt16) -> UUID {
        UUID(uuidString: "D1957F69-BAFB-4508-A4D1-573C606B" + index.toHexadecimal())!
    }
}

public extension ServiceType {
    
    static func solarHomeKit(_ index: UInt16) -> ServiceType {
        .custom(.solarHomeKit(index))
    }
}

public extension CharacteristicType {
    
    static func solarHomeKit(_ index: UInt16) -> CharacteristicType {
        .custom(.solarHomeKit(index))
    }
    
    static func solarFlag(_ flag: FlagStatus) -> CharacteristicType {
        let index = FlagStatus.allCases.firstIndex(of: flag) ?? 0
        return .solarHomeKit(400 + numericCast(index))
    }
}
