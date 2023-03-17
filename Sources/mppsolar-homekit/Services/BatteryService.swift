//
//  BatteryService.swift
//  
//
//  Created by Alsey Coleman Miller on 2/27/23.
//

#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation
import HAP
import MPPSolar

final class SolarBatteryService: Service.Battery {
    
    let batteryVoltage = GenericCharacteristic<Float>(
        type: .custom(UUID(uuidString: "5C7D8287-D288-4F4D-BB4A-161A83A99752")!),
        value: 0,
        permissions: [.read, .events],
        description: "Battery Voltage",
        format: .float,
        unit: .none
    )
    
    let batteryChargingCurrent = GenericCharacteristic<UInt8>(
        type: .solarHomeKit(1),
        value: 0,
        permissions: [.read, .events],
        description: "Battery Charging Current",
        format: .uint8,
        unit: .none
    )
    
    init() {
        let name = PredefinedCharacteristic.name("Battery")
        let batteryLevel = PredefinedCharacteristic.batteryLevel()
        let chargingState = PredefinedCharacteristic.chargingState()
        
        super.init(characteristics: [
            AnyCharacteristic(name),
            AnyCharacteristic(batteryLevel),
            AnyCharacteristic(chargingState),
            AnyCharacteristic(batteryVoltage),
            AnyCharacteristic(batteryChargingCurrent),
        ])
    }
}
