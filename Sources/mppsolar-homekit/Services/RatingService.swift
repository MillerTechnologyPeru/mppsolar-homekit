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
        permissions: [.read],
        description: "Grid rating voltage",
        format: .float,
        unit: .none
    )
    
    let gridRatingCurrent = GenericCharacteristic<Float>(
        type: .solarHomeKit(602),
        value: 0.0,
        permissions: [.read],
        description: "Grid rating current",
        format: .float,
        unit: .none
    )
    
    let outputRatingVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(603),
        value: 0.0,
        permissions: [.read],
        description: "AC output rating voltage",
        format: .float,
        unit: .none
    )
    
    let outputRatingFrequency = GenericCharacteristic<UInt8>(
        type: .solarHomeKit(604),
        value: 60,
        permissions: [.read, .events, .write],
        description: "AC output rating frequency",
        format: .uint8,
        unit: .none,
        maxValue: 60,
        minValue: 50,
        minStep: 10,
        validValues: OutputFrequency.allCases.map { Double($0.rawValue) }
    )
    
    let outputRatingCurrent = GenericCharacteristic<Float>(
        type: .solarHomeKit(605),
        value: 0.0,
        permissions: [.read],
        description: "AC output rating current",
        format: .float,
        unit: .none
    )
    
    let outputRatingApparentPower = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(606),
        value: 0,
        permissions: [.read],
        description: "AC output rating apparent power",
        format: .uint32,
        unit: .none
    )
    
    let outputRatingActivePower = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(607),
        value: 0,
        permissions: [.read],
        description: "AC output rating active power",
        format: .uint32,
        unit: .none
    )
    
    let batteryRatingVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(608),
        value: 0.0,
        permissions: [.read],
        description: "Battery rating voltage",
        format: .float,
        unit: .none
    )
    
    let batteryRechargeVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(609),
        value: 0.0,
        permissions: [.read],
        description: "Battery re-charge voltage",
        format: .float,
        unit: .none
    )
    
    let batteryUnderVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(610),
        value: 0.0,
        permissions: [.read],
        description: "Battery under voltage",
        format: .float,
        unit: .none
    )
    
    let batteryBulkVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(611),
        value: 0.0,
        permissions: [.read],
        description: "Battery bulk voltage",
        format: .float,
        unit: .none
    )
    
    let batteryFloatVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(612),
        value: 0.0,
        permissions: [.read],
        description: "Battery float voltage",
        format: .float,
        unit: .none
    )
    
    let batteryType = GenericCharacteristic<String>(
        type: .solarHomeKit(613),
        value: DeviceRating.BatteryType.agm.description,
        permissions: [.read],
        description: "Battery type",
        format: .string,
        unit: .none
    )
    
    let maxChargingCurrentAC = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(614),
        value: 0,
        permissions: [.read],
        description: "Max AC charging current",
        format: .uint32,
        unit: .none
    )
    
    let maxChargingCurrent = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(615),
        value: 0,
        permissions: [.read],
        description: "Max charging current",
        format: .uint32,
        unit: .none
    )
    
    let inputVoltageRange = GenericCharacteristic<String>(
        type: .solarHomeKit(616),
        value: "",
        permissions: [.read],
        description: "Input voltage range",
        format: .string,
        unit: .none
    )
    
    let outputSourcePriority = GenericCharacteristic<String>(
        type: .solarHomeKit(617),
        value: "",
        permissions: [.read],
        description: "Output source priority",
        format: .string,
        unit: .none
    )
    
    let chargerSourcePriority = GenericCharacteristic<String>(
        type: .solarHomeKit(618),
        value: "",
        permissions: [.read],
        description: "Charger source priority",
        format: .string,
        unit: .none
    )
    
    let maxParallel = GenericCharacteristic<UInt8>(
        type: .solarHomeKit(619),
        value: 0,
        permissions: [.read],
        description: "Max Parallel Units",
        format: .uint8,
        unit: .none
    )
    
    let machineType = GenericCharacteristic<String>(
        type: .solarHomeKit(620),
        value: "",
        permissions: [.read],
        description: "Machine type",
        format: .string,
        unit: .none
    )
    
    let topology = GenericCharacteristic<Bool>(
        type: .solarHomeKit(621),
        value: false,
        permissions: [.read],
        description: "Topology",
        format: .bool,
        unit: .none
    )
    
    let outputMode = GenericCharacteristic<String>(
        type: .solarHomeKit(622),
        value: "",
        permissions: [.read],
        description: "Output mode",
        format: .string,
        unit: .none
    )
    
    let batteryRedischargeVoltage = GenericCharacteristic<Float>(
        type: .solarHomeKit(623),
        value: 0.0,
        permissions: [.read],
        description: "Battery float voltage",
        format: .float,
        unit: .none
    )
    
    let isParallelAllPVRequired = GenericCharacteristic<Bool>(
        type: .solarHomeKit(624),
        value: false,
        permissions: [.read],
        description: "PV all connected for parallel",
        format: .bool,
        unit: .none
    )
    
    let isPVInputMaxSumLoad = GenericCharacteristic<Bool>(
        type: .solarHomeKit(625),
        value: false,
        permissions: [.read],
        description: "PV power balance",
        format: .bool,
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
                AnyCharacteristic(maxChargingCurrentAC),
                AnyCharacteristic(maxChargingCurrent),
                AnyCharacteristic(inputVoltageRange),
                AnyCharacteristic(outputSourcePriority),
                AnyCharacteristic(chargerSourcePriority),
                AnyCharacteristic(maxParallel),
                AnyCharacteristic(machineType),
                AnyCharacteristic(topology),
                AnyCharacteristic(outputMode),
                AnyCharacteristic(batteryRedischargeVoltage),
                AnyCharacteristic(isParallelAllPVRequired),
                AnyCharacteristic(isPVInputMaxSumLoad),
            ]
        )
    }
}
