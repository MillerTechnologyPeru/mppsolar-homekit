//
//  InverterService.swift
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
    
    let chargingStatusAC = GenericCharacteristic<Bool>(
        type: .solarHomeKit(112),
        value: false,
        permissions: [.read, .events],
        description: "AC charging",
        format: .bool,
        unit: .none
    )
    
    let chargingStatusSCC = GenericCharacteristic<Bool>(
        type: .solarHomeKit(113),
        value: false,
        permissions: [.read, .events],
        description: "SCC charging",
        format: .bool,
        unit: .none
    )
    
    let isCharging = GenericCharacteristic<Bool>(
        type: .solarHomeKit(114),
        value: false,
        permissions: [.read, .events],
        description: "Charging",
        format: .bool,
        unit: .none
    )
    
    let batteryVoltageSteady = GenericCharacteristic<Bool>(
        type: .solarHomeKit(115),
        value: false,
        permissions: [.read, .events],
        description: "Battery voltage to steady while charging",
        format: .bool,
        unit: .none
    )
    
    let isLoadEnabled = GenericCharacteristic<Bool>(
        type: .solarHomeKit(116),
        value: false,
        permissions: [.read, .events],
        description: "Load status",
        format: .bool,
        unit: .none
    )
    
    let sccFirmareUpdated = GenericCharacteristic<Bool>(
        type: .solarHomeKit(117),
        value: false,
        permissions: [.read, .events],
        description: "SCC firmware version updated",
        format: .bool,
        unit: .none
    )
    
    let configurationChanged = GenericCharacteristic<Bool>(
        type: .solarHomeKit(118),
        value: false,
        permissions: [.read, .events],
        description: "Configuration changed",
        format: .bool,
        unit: .none
    )
    
    let addSBUPriorityVersion = GenericCharacteristic<Bool>(
        type: .solarHomeKit(119),
        value: false,
        permissions: [.read, .events],
        description: "Add SBU priority version",
        format: .bool,
        unit: .none
    )
    
    let protocolID = GenericCharacteristic<UInt32>(
        type: .solarHomeKit(200),
        value: 0,
        permissions: [.read],
        description: "Protocol ID",
        format: .uint32,
        unit: .none
    )
    
    let warningStatus = GenericCharacteristic<String>(
        type: .solarHomeKit(300),
        value: "",
        permissions: [.read, .events],
        description: "Warning Status",
        format: .string,
        unit: .none
    )
    
    let buzzer = GenericCharacteristic<Bool>(
        type: .solarHomeKit(400),
        value: false,
        permissions: [.read, .write, .events],
        description: "Buzzer",
        format: .bool,
        unit: .none
    )
    
    let overloadBypass = GenericCharacteristic<Bool>(
        type: .solarHomeKit(401),
        value: false,
        permissions: [.read, .write, .events],
        description: "Overload bypass",
        format: .bool,
        unit: .none
    )
    
    let powerSaving = GenericCharacteristic<Bool>(
        type: .solarHomeKit(402),
        value: false,
        permissions: [.read, .write, .events],
        description: "Power saving",
        format: .bool,
        unit: .none
    )
    
    let displayTimeout = GenericCharacteristic<Bool>(
        type: .solarHomeKit(403),
        value: false,
        permissions: [.read, .write, .events],
        description: "LCD display timeout",
        format: .bool,
        unit: .none
    )
    
    let overloadRestart = GenericCharacteristic<Bool>(
        type: .solarHomeKit(404),
        value: false,
        permissions: [.read, .write, .events],
        description: "Overload Restart",
        format: .bool,
        unit: .none
    )
    
    let temperatureRestart = GenericCharacteristic<Bool>(
        type: .solarHomeKit(405),
        value: false,
        permissions: [.read, .write, .events],
        description: "Temperature restart",
        format: .bool,
        unit: .none
    )
    
    let backlight = GenericCharacteristic<Bool>(
        type: .solarHomeKit(406),
        value: false,
        permissions: [.read, .write, .events],
        description: "LCD display backlight",
        format: .bool,
        unit: .none
    )
    
    let interruptAlarm = GenericCharacteristic<Bool>(
        type: .solarHomeKit(407),
        value: false,
        permissions: [.read, .write, .events],
        description: "Interrupt Alarm",
        format: .bool,
        unit: .none
    )
    
    let recordFault = GenericCharacteristic<Bool>(
        type: .solarHomeKit(408),
        value: false,
        permissions: [.read, .write, .events],
        description: "Fault code record",
        format: .bool,
        unit: .none
    )
    
    let firmwareVersion = GenericCharacteristic<String>(
        type: .solarHomeKit(500),
        value: "",
        permissions: [.read, .events],
        description: "CPU Firmware Version",
        format: .string,
        unit: .none
    )
    
    let firmwareVersion2 = GenericCharacteristic<String>(
        type: .solarHomeKit(501),
        value: "",
        permissions: [.read, .events],
        description: "Secondary CPU Firmware Version",
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
            AnyCharacteristic(protocolID),
            AnyCharacteristic(warningStatus),
            AnyCharacteristic(chargingStatusAC),
            AnyCharacteristic(chargingStatusSCC),
            AnyCharacteristic(isCharging),
            AnyCharacteristic(batteryVoltageSteady),
            AnyCharacteristic(isLoadEnabled),
            AnyCharacteristic(sccFirmareUpdated),
            AnyCharacteristic(configurationChanged),
            AnyCharacteristic(addSBUPriorityVersion),
            AnyCharacteristic(buzzer),
            AnyCharacteristic(overloadBypass),
            AnyCharacteristic(powerSaving),
            AnyCharacteristic(displayTimeout),
            AnyCharacteristic(overloadRestart),
            AnyCharacteristic(temperatureRestart),
            AnyCharacteristic(backlight),
            AnyCharacteristic(interruptAlarm),
            AnyCharacteristic(recordFault),
            AnyCharacteristic(firmwareVersion),
            AnyCharacteristic(firmwareVersion2),
        ])
    }
}
