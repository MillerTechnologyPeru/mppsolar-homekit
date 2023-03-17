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
    
    let battery = SolarBatteryService()
    let inverter = InverterService()
    let rating = RatingService()
    let firmware = FirmwareService()
    
    init(info: Service.Info) {
        super.init(
            info: info,
            type: .outlet,
            services: [
                battery,
                inverter,
                rating,
                firmware
            ]
        )
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
        firmware.protocolID.value = UInt32(protocolID.rawValue)
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
        inverter.outletInUse?.value = status.outputActivePower > 0
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
        inverter.statusFault.value = statusText == "[]" ? 0 : 1
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
        self.firmware.firmwareVersion.value = firmware.rawValue
    }
    
    func update(secondary firmware: FirmwareVersion) {
        self.firmware.firmwareVersion2.value = firmware.rawValue
    }
    
    func update(rating ratingInfo: DeviceRating) {
        rating.gridRatingVoltage.value = format(ratingInfo.gridRatingVoltage)
        rating.gridRatingCurrent.value = format(ratingInfo.gridRatingCurrent)
        rating.outputRatingVoltage.value = format(ratingInfo.outputRatingVoltage)
        rating.outputRatingFrequency.value = UInt8(ratingInfo.outputRatingFrequency.rounded())
        rating.outputRatingCurrent.value = format(ratingInfo.outputRatingCurrent)
        rating.outputRatingApparentPower.value = numericCast(ratingInfo.outputRatingApparentPower)
        rating.outputRatingActivePower.value = numericCast(ratingInfo.outputRatingActivePower)
        rating.batteryRatingVoltage.value = format(ratingInfo.batteryRatingVoltage)
        rating.batteryRechargeVoltage.value = format(ratingInfo.batteryRechargeVoltage)
        rating.batteryUnderVoltage.value = format(ratingInfo.batteryUnderVoltage)
        rating.batteryBulkVoltage.value = format(ratingInfo.batteryBulkVoltage)
        rating.batteryFloatVoltage.value = format(ratingInfo.batteryFloatVoltage)
        rating.batteryType.value = ratingInfo.batteryType.description
        rating.maxChargingCurrentAC.value = numericCast(ratingInfo.maxChargingCurrentAC)
        rating.maxChargingCurrent.value = numericCast(ratingInfo.maxChargingCurrent)
        rating.inputVoltageRange.value = ratingInfo.inputVoltageRange.description
        rating.outputSourcePriority.value = ratingInfo.outputSourcePriority.description
        rating.chargerSourcePriority.value = ratingInfo.chargerSourcePriority.description
        rating.maxParallel.value = numericCast(ratingInfo.maxParallel)
        rating.machineType.value = ratingInfo.inputVoltageRange.description
        rating.topology.value = ratingInfo.topology
        rating.outputMode.value = ratingInfo.outputMode.description
        rating.batteryRedischargeVoltage.value = format(ratingInfo.batteryRedischargeVoltage)
        rating.isParallelAllPVRequired.value = ratingInfo.isParallelAllPVRequired
        rating.isPVInputMaxSumLoad.value = ratingInfo.isPVInputMaxSumLoad
    }
    
    func format(_ value: Float) -> Float {
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
