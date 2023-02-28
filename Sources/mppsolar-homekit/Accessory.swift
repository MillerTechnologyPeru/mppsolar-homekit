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

final class SolarInverterAccessory: Accessory {
    
    let battery = BatteryService()
    let inverter = InverterService()
    
    init(info: Service.Info) {
        super.init(
            info: info,
            type: .outlet,
            services: [
                battery,
                inverter,
            ]
        )
    }
}

extension SolarInverterAccessory {
    
    final class BatteryService: Service.Battery {
        
        let batteryVoltage = GenericCharacteristic<Float>(
            type: .solarHomeKit(0),
            value: 0,
            permissions: [.read, .events],
            description: "Battery voltage",
            format: .float,
            unit: .none
        )
        
        let batteryChargingCurrent = GenericCharacteristic<UInt8>(
            type: .solarHomeKit(1),
            value: 0,
            permissions: [.read, .events],
            description: "Battery charging current",
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
    
    final class InverterService: Service.Outlet {
                
        let deviceMode = GenericCharacteristic<String>(
            type: .solarHomeKit(100),
            value: "",
            permissions: [.read, .events],
            description: "Mode",
            format: .string,
            unit: .none
        )
        
        let outputLoadPercent = GenericCharacteristic<UInt8>(
            type: .solarHomeKit(101),
            value: 0,
            permissions: [.read, .events],
            description: "Output load percent",
            format: .uint8,
            unit: .percentage
        )
        
        let outputVoltage = GenericCharacteristic<Float>(
            type: .solarHomeKit(102),
            value: 0.0,
            permissions: [.read, .events],
            description: "AC output voltage",
            format: .float,
            unit: .none
        )
        
        let outputFrequency = GenericCharacteristic<Float>(
            type: .solarHomeKit(103),
            value: 0.0,
            permissions: [.read, .events],
            description: "AC output frequency",
            format: .float,
            unit: .none
        )
        
        let outputApparentPower = GenericCharacteristic<UInt16>(
            type: .solarHomeKit(104),
            value: 0,
            permissions: [.read, .events],
            description: "AC output apparent power",
            format: .uint16,
            unit: .none
        )
        
        let outputActivePower = GenericCharacteristic<UInt16>(
            type: .solarHomeKit(105),
            value: 0,
            permissions: [.read, .events],
            description: "AC output active power",
            format: .uint16,
            unit: .none
        )
        
        let busVoltage = GenericCharacteristic<UInt16>(
            type: .solarHomeKit(106),
            value: 0,
            permissions: [.read, .events],
            description: "Bus voltage",
            format: .uint16,
            unit: .none
        )
        
        let inverterHeatSinkTemperature = GenericCharacteristic<Int>(
            type: .solarHomeKit(107),
            value: 0,
            permissions: [.read, .events],
            description: "Inverter heat sink temperature",
            format: .int,
            unit: .celsius
        )
        
        let solarInputCurrent: GenericCharacteristic<UInt32> = GenericCharacteristic<UInt32>(
            type: .solarHomeKit(108),
            value: 0,
            permissions: [.read, .events],
            description: "PV input current",
            format: .uint32,
            unit: .none
        )
        
        let solarInputVoltage = GenericCharacteristic<Float>(
            type: .solarHomeKit(109),
            value: 0,
            permissions: [.read, .events],
            description: "PV input voltage",
            format: .float,
            unit: .none
        )
        
        let gridVoltage = GenericCharacteristic<Float>(
            type: .solarHomeKit(110),
            value: 0.0,
            permissions: [.read, .events],
            description: "Grid voltage",
            format: .float,
            unit: .none
        )
        
        let gridFrequency = GenericCharacteristic<Float>(
            type: .solarHomeKit(111),
            value: 0.0,
            permissions: [.read, .events],
            description: "Grid frequency",
            format: .float,
            unit: .none
        )
        
        let warningStatus = GenericCharacteristic<String>(
            type: .solarHomeKit(112),
            value: "",
            permissions: [.read, .events],
            description: "Warning Status",
            format: .string,
            unit: .none
        )
        
        init() {
            let name = PredefinedCharacteristic.name("Inverter")
            let outletInUse = PredefinedCharacteristic.outletInUse()
            super.init(characteristics: [
                AnyCharacteristic(name),
                AnyCharacteristic(outletInUse),
                AnyCharacteristic(deviceMode),
                AnyCharacteristic(outputLoadPercent),
                AnyCharacteristic(outputVoltage),
                AnyCharacteristic(outputFrequency),
                AnyCharacteristic(outputApparentPower),
                AnyCharacteristic(outputActivePower),
                AnyCharacteristic(busVoltage),
                AnyCharacteristic(inverterHeatSinkTemperature),
                AnyCharacteristic(solarInputCurrent),
                AnyCharacteristic(solarInputVoltage),
                AnyCharacteristic(gridVoltage),
                AnyCharacteristic(gridFrequency),
                AnyCharacteristic(warningStatus),
            ])
        }
    }
}

extension SolarInverterAccessory {
    
    func update(mode: DeviceMode) {
        inverter.deviceMode.value = mode.description
    }
    
    func update(serial: SerialNumber) {
        info.serialNumber.value = serial.rawValue
    }
    
    func update(status: GeneralStatus) {
        
        battery.batteryVoltage.value = format(status.batteryVoltage)
        battery.batteryChargingCurrent.value = UInt8(status.batteryChargingCurrent)
        assert(battery.batteryLevel != nil, "Missing battery level characteristic")
        battery.batteryLevel?.value = UInt8(status.batteryCapacity)
        assert(battery.chargingState != nil, "Missing charging state characteristic")
        battery.chargingState?.value = status.chargingState
        battery.statusLowBattery.value = status.statusLowBattery
        
        inverter.gridVoltage.value = format(status.gridVoltage)
        inverter.gridFrequency.value = format(status.gridFrequency)
        inverter.outputVoltage.value = format(status.outputVoltage)
        inverter.outputFrequency.value = format(status.outputFrequency)
        inverter.outputApparentPower.value = UInt16(status.outputApparentPower)
        inverter.outputActivePower.value = UInt16(status.outputActivePower)
        inverter.outputLoadPercent.value = UInt8(status.outputLoadPercent)
        inverter.busVoltage.value = UInt16(status.busVoltage)
        inverter.inverterHeatSinkTemperature.value = status.inverterHeatSinkTemperature
        inverter.solarInputCurrent.value = UInt32(status.solarInputCurrent)
        inverter.solarInputVoltage.value = format(status.solarInputVoltage)
        inverter.powerState.value = status.outputVoltage > 0
        assert(inverter.outletInUse != nil, "Missing outlet in use characteristic")
        inverter.outletInUse?.value = status.outputLoadPercent > 0
    }
    
    func update(warning: WarningStatus) {
        
        let statusText = warning.description
        inverter.warningStatus.value = statusText == "[]" ? "None" : statusText
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
        return (batteryCapacity < 25) ? .batteryLow : .batteryNormal
    }
}
