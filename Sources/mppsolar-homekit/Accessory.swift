//
//  Accessory.swift
//  
//
//  Created by Alsey Coleman Miller on 7/23/20.
//

#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation
import HAP
import MPPSolar

final class SolarAccessory: Accessory {
    
    let battery = BatteryService()
    let solarService = SolarService()
    
    init(info: Service.Info) {
        super.init(
            info: info,
            type: .outlet,
            services: [
                solarService,
                battery
            ]
        )
    }
}

extension SolarAccessory {
    
    final class SolarService: Service {
        
        let deviceMode = GenericCharacteristic<String>(
            type: .custom(UUID(uuidString: "93BDE3A4-1D30-4B61-9783-20463CDA1F55")!),
            value: "",
            permissions: [.read, .events],
            description: "Mode",
            format: .string,
            unit: .none
        )
        
        let gridVoltage = GenericCharacteristic<Float>(
            type: .custom(UUID(uuidString: "F1C1B6BB-0970-42B5-81AC-6C730B0EEC70")!),
            value: 0.0,
            permissions: [.read, .events],
            description: "Grid voltage",
            format: .float,
            unit: .none
        )
        
        let gridFrequency = GenericCharacteristic<Float>(
            type: .custom(UUID(uuidString: "75E985E8-7020-474F-95D8-728EDC9007FB")!),
            value: 0.0,
            permissions: [.read, .events],
            description: "Grid frequency",
            format: .float,
            unit: .none
        )
        
        let outputVoltage = GenericCharacteristic<Float>(
            type: .custom(UUID(uuidString: "ED5F71E0-99CE-4A7C-B183-316DBE7E8FDF")!),
            value: 0.0,
            permissions: [.read, .events],
            description: "AC output voltage",
            format: .float,
            unit: .none
        )
        
        let outputFrequency = GenericCharacteristic<Float>(
            type: .custom(UUID(uuidString: "9DFE7EF8-D115-495C-BC96-A444F6DE4B97")!),
            value: 0.0,
            permissions: [.read, .events],
            description: "AC output frequency",
            format: .float,
            unit: .none
        )
        
        let outputApparentPower = GenericCharacteristic<UInt16>(
            type: .custom(UUID(uuidString: "D872BBE1-ECCA-4339-A937-6FB9B4EC799D")!),
            value: 0,
            permissions: [.read, .events],
            description: "AC output apparent power",
            format: .uint16,
            unit: .none
        )
        
        let outputActivePower = GenericCharacteristic<UInt16>(
            type: .custom(UUID(uuidString: "9171E149-D44B-45BF-8D7D-2486F8479529")!),
            value: 0,
            permissions: [.read, .events],
            description: "AC output active power",
            format: .uint16,
            unit: .none
        )
        
        let outputLoadPercent = GenericCharacteristic<UInt8>(
            type: .custom(UUID(uuidString: "56e67656-cc74-4348-9fb4-fdaa71084601")!),
            value: 0,
            permissions: [.read, .events],
            description: "Output load percent",
            format: .uint8,
            unit: .percentage
        )
        
        let busVoltage = GenericCharacteristic<UInt16>(
            type: .custom(UUID(uuidString: "F4E3BA74-1118-4CF3-A5B4-F7DC65EC3DC6")!),
            value: 0,
            permissions: [.read, .events],
            description: "Bus voltage",
            format: .uint16,
            unit: .none
        )
        
        let batteryVoltage = GenericCharacteristic<Float>(
            type: .custom(UUID(uuidString: "A242A709-40C9-4617-9C2F-DE15861B4FE1")!),
            value: 0,
            permissions: [.read, .events],
            description: "Battery voltage",
            format: .float,
            unit: .none
        )
        
        let batteryChargingCurrent = GenericCharacteristic<UInt8>(
            type: .custom(UUID(uuidString: "082849CB-E073-4951-BB9F-70ED58389BEB")!),
            value: 0,
            permissions: [.read, .events],
            description: "Battery charging current",
            format: .uint8,
            unit: .none
        )
        
        let inverterHeatSinkTemperature = GenericCharacteristic<Int>(
            type: .custom(UUID(uuidString: "F6F89F38-B5A4-4CB3-9426-2334CF061F73")!),
            value: 0,
            permissions: [.read, .events],
            description: "Inverter heat sink temperature",
            format: .int,
            unit: .celsius
        )
        
        let solarInputCurrent: GenericCharacteristic<UInt32> = GenericCharacteristic<UInt32>(
            type: .custom(UUID(uuidString: "457BDB91-60E4-4FCE-9F20-57B1912A3284")!),
            value: 0,
            permissions: [.read, .events],
            description: "PV input current",
            format: .uint32,
            unit: .none
        )
        
        let solarInputVoltage = GenericCharacteristic<Float>(
            type: .custom(UUID(uuidString: "2E910C09-A0BE-4BE5-B035-7C0640A3CDB9")!),
            value: 0,
            permissions: [.read, .events],
            description: "PV input voltage",
            format: .float,
            unit: .none
        )
        
        init() {
            super.init(type: .outlet, characteristics: [
                AnyCharacteristic(deviceMode),
                AnyCharacteristic(gridVoltage),
                AnyCharacteristic(gridFrequency),
                AnyCharacteristic(outputVoltage),
                AnyCharacteristic(outputFrequency),
                AnyCharacteristic(outputApparentPower),
                AnyCharacteristic(outputActivePower),
                AnyCharacteristic(outputLoadPercent),
                AnyCharacteristic(busVoltage),
                AnyCharacteristic(batteryVoltage),
                AnyCharacteristic(batteryChargingCurrent),
                AnyCharacteristic(inverterHeatSinkTemperature),
                AnyCharacteristic(solarInputCurrent),
                AnyCharacteristic(solarInputVoltage),
            ])
        }
    }

    final class BatteryService: Service.Battery {
        
        init() {
            let name = GenericCharacteristic<String>(
                type: .name, 
                value: "Solar Battery", 
                permissions: [.read],
                 format: .string,
                  unit: .none
            )
            let batteryLevel = PredefinedCharacteristic.batteryLevel()
            let chargingState = PredefinedCharacteristic.chargingState()

            super.init(characteristics: [
                AnyCharacteristic(name),
                AnyCharacteristic(batteryLevel),
                AnyCharacteristic(chargingState)
            ])
        }
    }
}

extension DeviceMode: CharacteristicValueType { }

extension SolarAccessory {
    
    func update(mode: DeviceMode,
                status: GeneralStatus,
                serial: SerialNumber) {
        
        info.serialNumber.value = serial.rawValue
        
        solarService.deviceMode.value = mode.description
        solarService.gridVoltage.value = format(status.gridVoltage)
        solarService.gridFrequency.value = format(status.gridFrequency)
        solarService.outputVoltage.value = format(status.outputVoltage)
        solarService.outputFrequency.value = format(status.outputFrequency)
        solarService.outputApparentPower.value = UInt16(status.outputApparentPower)
        solarService.outputActivePower.value = UInt16(status.outputActivePower)
        solarService.outputLoadPercent.value = UInt8(status.outputLoadPercent)
        solarService.busVoltage.value = UInt16(status.busVoltage)
        solarService.batteryVoltage.value = format(status.batteryVoltage)
        solarService.batteryChargingCurrent.value = UInt8(status.batteryChargingCurrent)
        solarService.inverterHeatSinkTemperature.value = status.inverterHeatSinkTemperature
        solarService.solarInputCurrent.value = UInt32(status.solarInputCurrent)
        solarService.solarInputVoltage.value = format(status.solarInputVoltage)
        
        assert(battery.batteryLevel != nil, "Missing battery level characteristic")
        battery.batteryLevel?.value = UInt8(status.batteryCapacity)
        assert(battery.chargingState != nil, "Missing charging state characteristic")
        battery.chargingState?.value = status.chargingState
        battery.statusLowBattery.value = status.statusLowBattery
    }

    private func format(_ value: Float) -> Float {
        Float(Int(value * 100)) / 100.0
    }
}

extension GeneralStatus {

    var chargingState: HAP.Enums.ChargingState {
        return batteryChargingCurrent > 0 ? .charging : .notCharging
    }

    var statusLowBattery: HAP.Enums.StatusLowBattery {
        return (batteryCapacity < 10) ? .batteryLow : .batteryNormal
    }
}
