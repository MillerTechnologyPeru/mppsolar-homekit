//
//  FirmwareService.swift
//  
//
//  Created by Alsey Coleman Miller on 2/27/23.
//

import Foundation
import HAP
import MPPSolar

public final class FirmwareService: Service {
    
    let protocolID = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(201),
        value: 0,
        permissions: [.read],
        description: "Protocol ID",
        format: .uint32,
        unit: .none
    )
    
    let firmwareVersion = GenericCharacteristic<String>(
        type: .solarHomeKit(202),
        value: "",
        permissions: [.read],
        description: "CPU Firmware Version",
        format: .string,
        unit: .none
    )
    
    let firmwareVersion2 = GenericCharacteristic<String>(
        type: .solarHomeKit(203),
        value: "",
        permissions: [.read],
        description: "Secondary CPU Firmware Version",
        format: .string,
        unit: .none
    )
    
    init() {
        let name = PredefinedCharacteristic.name("Firmware")
        super.init(
            type: .solarHomeKit(200),
            characteristics: [
                AnyCharacteristic(name),
                AnyCharacteristic(protocolID),
                AnyCharacteristic(firmwareVersion),
                AnyCharacteristic(firmwareVersion2),
            ]
        )
    }
}
