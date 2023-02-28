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
    let rating = RatingService()
    
    init(info: Service.Info) {
        super.init(
            info: info,
            type: .outlet,
            services: [
                battery,
                inverter,
                rating
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
            super.init(
                type: .solarHomeKit(600),
                characteristics: [
                    AnyCharacteristic(gridRatingVoltage),
                    AnyCharacteristic(gridRatingCurrent),
                    AnyCharacteristic(outputRatingVoltage),
                    AnyCharacteristic(outputRatingFrequency),
                    AnyCharacteristic(outputRatingCurrent),
                    AnyCharacteristic(outputRatingApparentPower),
                    AnyCharacteristic(outputRatingActivePower),
                    AnyCharacteristic(batteryRatingVoltage),
                    AnyCharacteristic(outputRatingActivePower),
                    AnyCharacteristic(batteryUnderVoltage),
                    AnyCharacteristic(batteryBulkVoltage),
                    AnyCharacteristic(batteryFloatVoltage),
                    AnyCharacteristic(batteryType),
                ]
            )
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
    
    func update(protocolID: ProtocolID) {
        inverter.protocolID.value = UInt32(protocolID.rawValue)
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
        inverter.chargingStatusAC.value = status.flags.contains(.chargingStatusAC)
        inverter.chargingStatusSCC.value = status.flags.contains(.chargingStatusSCC)
        
        inverter.isCharging.value = status.flags.contains(.isCharging)
        inverter.batteryVoltageSteady.value = status.flags.contains(.batteryVoltageSteady)
        inverter.isLoadEnabled.value = status.flags.contains(.isLoadEnabled)
        inverter.sccFirmareUpdated.value = status.flags.contains(.sccFirmareUpdated)
        inverter.configurationChanged.value = status.flags.contains(.configurationChanged)
        inverter.addSBUPriorityVersion.value = status.flags.contains(.addSBUPriorityVersion)
    }
    
    func update(warning: WarningStatus) {
        
        let statusText = warning.description
        inverter.warningStatus.value = statusText == "[]" ? "None" : statusText
    }
    
    func update(flags: FlagStatus.Query.Response) {
        
        inverter.buzzer.value = flags.enabled.contains(.buzzer)
        inverter.overloadBypass.value = flags.enabled.contains(.overloadBypass)
        inverter.powerSaving.value = flags.enabled.contains(.powerSaving)
        inverter.displayTimeout.value = flags.enabled.contains(.displayTimeout)
        inverter.overloadRestart.value = flags.enabled.contains(.overloadRestart)
        inverter.temperatureRestart.value = flags.enabled.contains(.temperatureRestart)
        inverter.backlight.value = flags.enabled.contains(.backlight)
        inverter.interruptAlarm.value = flags.enabled.contains(.alarm)
        inverter.recordFault.value = flags.enabled.contains(.recordFault)
    }
    
    func update(firmware: FirmwareVersion) {
        inverter.firmwareVersion.value = firmware.rawValue
    }
    
    func update(secondary firmware: FirmwareVersion) {
        inverter.firmwareVersion2.value = firmware.rawValue
    }
    
    func update(rating ratingInfo: DeviceRating) {
        rating.gridRatingVoltage.value = format(ratingInfo.gridRatingVoltage)
        rating.gridRatingCurrent.value = format(ratingInfo.gridRatingCurrent)
        rating.outputRatingVoltage.value = format(ratingInfo.outputRatingVoltage)
        rating.outputRatingFrequency.value = format(ratingInfo.outputRatingFrequency)
        rating.outputRatingCurrent.value = format(ratingInfo.outputRatingCurrent)
        rating.outputRatingApparentPower.value = numericCast(ratingInfo.outputRatingApparentPower)
        rating.outputRatingActivePower.value = numericCast(ratingInfo.outputRatingActivePower)
        rating.batteryRatingVoltage.value = format(ratingInfo.batteryRatingVoltage)
        rating.batteryRechargeVoltage.value = format(ratingInfo.batteryRechargeVoltage)
        rating.batteryUnderVoltage.value = format(ratingInfo.batteryUnderVoltage)
        rating.batteryBulkVoltage.value = format(ratingInfo.batteryBulkVoltage)
        rating.batteryFloatVoltage.value = format(ratingInfo.batteryFloatVoltage)
        rating.batteryType.value = ratingInfo.batteryType.description
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
