//
//  RatingService.swift
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

final class RatingService: Service {
    
    let gridRatingVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(601),
        value: 0.0,
        permissions: [.read, .events],
        description: "Grid rating voltage",
        format: .float,
        unit: .none
    )
    
    let gridRatingCurrent = GenericCharacteristic<Float>(
        type: .solarHomeKit(602),
        value: 0.0,
        permissions: [.read, .events],
        description: "Grid rating current",
        format: .float,
        unit: .none
    )
    
    let outputRatingVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(603),
        value: 0.0,
        permissions: [.read, .events],
        description: "AC output rating voltage",
        format: .float,
        unit: .none
    )
    
    let outputRatingFrequency = GenericCharacteristic<Float>(
        type: .solarHomeKit(604),
        value: 0.0,
        permissions: [.read, .events],
        description: "AC output rating frequency",
        format: .float,
        unit: .none
    )
    
    let outputRatingCurrent = GenericCharacteristic<Float>(
        type: .solarHomeKit(605),
        value: 0.0,
        permissions: [.read, .events],
        description: "AC output rating current",
        format: .float,
        unit: .none
    )
    
    let outputRatingApparentPower = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(606),
        value: 0,
        permissions: [.read, .events],
        description: "AC output rating apparent power",
        format: .uint32,
        unit: .none
    )
    
    let outputRatingActivePower = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(607),
        value: 0,
        permissions: [.read, .events],
        description: "AC output rating active power",
        format: .uint32,
        unit: .none
    )
    
    let batteryRatingVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(608),
        value: 0.0,
        permissions: [.read, .events],
        description: "Battery rating voltage",
        format: .float,
        unit: .none
    )
    
    let batteryRechargeVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(609),
        value: 0.0,
        permissions: [.read, .events],
        description: "Battery re-charge voltage",
        format: .float,
        unit: .none
    )
    
    let batteryUnderVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(610),
        value: 0.0,
        permissions: [.read, .events],
        description: "Battery under voltage",
        format: .float,
        unit: .none
    )
    
    let batteryBulkVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(611),
        value: 0.0,
        permissions: [.read, .events],
        description: "Battery bulk voltage",
        format: .float,
        unit: .none
    )
    
    let batteryFloatVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(612),
        value: 0.0,
        permissions: [.read, .events],
        description: "Battery float voltage",
        format: .float,
        unit: .none
    )
    
    let batteryType = GenericCharacteristic<String>(
        type: .solarHomeKit(613),
        value: DeviceRating.BatteryType.agm.description,
        permissions: [.read, .events],
        description: "Battery type",
        format: .string,
        unit: .none
    )
    
    init() {
        let name = PredefinedCharacteristic.name("Firmware")
        super.init(
            type: .solarHomeKit(600),
            characteristics: [
                AnyCharacteristic(name),
                AnyCharacteristic(gridRatingVoltage),
                AnyCharacteristic(gridRatingCurrent),
                AnyCharacteristic(outputRatingVoltage),
                AnyCharacteristic(outputRatingFrequency),
                AnyCharacteristic(outputRatingCurrent),
                AnyCharacteristic(outputRatingApparentPower),
                AnyCharacteristic(outputRatingActivePower),
                AnyCharacteristic(batteryRatingVoltage),
                AnyCharacteristic(batteryRechargeVoltage),
                AnyCharacteristic(batteryUnderVoltage),
                AnyCharacteristic(batteryBulkVoltage),
                AnyCharacteristic(batteryFloatVoltage),
                AnyCharacteristic(batteryType),
            ]
        )
    }
}
