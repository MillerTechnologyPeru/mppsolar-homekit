//
//  Controller.swift
//  
//
//  Created by Alsey Coleman Miller on 7/24/20.
//

import Foundation
import MPPSolar
import HAP

final class SolarController {
    
    // MARK: - Properties
    
    var log: ((String) -> ())?
    
    let refreshInterval: TimeInterval
    
    private let filePath: String
    
    private let accessory: SolarInverterAccessory
    
    private let hapDevice: HAP.Device
    
    private let server: HAP.Server
    
    private var refreshTimer: Timer?
    
    // MARK: - Initialization
    
    public init(device path: String,
                refreshInterval: TimeInterval,
                fileName: String,
                setupCode: HAP.Device.SetupCode,
                port: UInt,
                model: String) throws {
        
        // start server
        let accessory = SolarInverterAccessory(
            info: Service.Info(
                name: "MPP Solar Inverter",
                serialNumber: "0000",
                manufacturer: "MPP Solar",
                model: model,
                firmwareRevision: MPPSolarHomeKitTool.configuration.version
            )
        )
        let storage = FileStorage(filename: fileName)
        let hapDevice = HAP.Device(
            setupCode: setupCode,
            storage: storage,
            accessory: accessory
        )
        self.filePath = path
        self.refreshInterval = refreshInterval
        self.accessory = accessory
        self.hapDevice = hapDevice
        self.server = try HAP.Server(device: hapDevice, listenPort: Int(port))
        self.hapDevice.delegate = self
        // refresh info
        refresh()
        refreshTimer = .scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in self?.refresh() }
    }
    
    // MARK: - Methods
    
    private func device<T>(_ block: (MPPSolar) throws -> (T)) throws -> T {
        guard let device = MPPSolar(path: filePath)
            else { throw CommandError.deviceUnavailable }
        return try block(device)
    }
    
    private func refresh(_ device: MPPSolar) throws {
        let protocolID = try device.send(ProtocolID.Query()).protocolID
        self.accessory.update(protocolID: protocolID)
        let mode = try device.send(DeviceMode.Query())
        self.accessory.update(mode: mode)
        let serialNumber = try device.send(SerialNumber.Query()).serialNumber
        self.accessory.update(serial: serialNumber)
        let status = try device.send(GeneralStatus.Query())
        self.accessory.update(status: status)
        let warning = try device.send(WarningStatus.Query())
        self.accessory.update(warning: warning)
        let flags = try device.send(FlagStatus.Query())
        self.accessory.update(flags: flags)
        let firmwareVersion = try device.send(FirmwareVersion.Query()).version
        self.accessory.update(firmware: firmwareVersion)
        let firmwareVersion2 = try device.send(FirmwareVersion.Query.Secondary()).version
        self.accessory.update(secondary: firmwareVersion2)
        let rating = try device.send(DeviceRating.Query())
        self.accessory.update(rating: rating)
    }
    
    func refresh() {
        
        do {
            try device {
                try refresh($0)
            }
        }
        catch { log?("Error: Could not refresh device information. \(error)") }
    }
    
    func didChange(flag: FlagStatus, newValue: Bool) {
        do {
            let setting: FlagStatus.Setting = newValue ? .init(enabled: [flag]) : .init(disabled: [flag])
            try device {
                let _ = try $0.send(setting)
                log?("\(newValue ? "Enabled" : "Disabled") \(flag.description)")
                try refresh($0)
            }
        }
        catch { log?("Error: Could not set \(flag.description). \(error)") }
    }
    
    func didChange(frequency: OutputFrequency) {
        do {
            try device {
                let _ = try $0.send(OutputFrequency.Setting(frequency: frequency))
                log?("Set output frequency to \(frequency)")
                try refresh($0)
            }
        }
        catch { log?("Error: Could not set output frequency to \(frequency). \(error)") }
    }
}

// MARK: - HAP Device Delegate

extension SolarController: HAP.DeviceDelegate {
    
    func didRequestIdentificationOf(_ accessory: Accessory) {
        log?("Requested identification of accessory \(String(describing: accessory.info.name.value ?? ""))")
    }

    func characteristic<T>(_ characteristic: GenericCharacteristic<T>,
                           ofService service: Service,
                           ofAccessory accessory: Accessory,
                           didChangeValue newValue: T?) {
        log?("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") did change: \(String(describing: newValue))")
        switch characteristic.type {
        case .solarFlag(.buzzer):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .buzzer, newValue: value)
        case .solarFlag(.overloadBypass):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .overloadBypass, newValue: value)
        case .solarFlag(.powerSaving):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .powerSaving, newValue: value)
        case .solarFlag(.displayTimeout):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .displayTimeout, newValue: value)
        case .solarFlag(.overloadRestart):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .overloadRestart, newValue: value)
        case .solarFlag(.temperatureRestart):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .temperatureRestart, newValue: value)
        case .solarFlag(.backlight):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .backlight, newValue: value)
        case .solarFlag(.alarm):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .alarm, newValue: value)
        case .solarFlag(.recordFault):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            didChange(flag: .recordFault, newValue: value)
        case .solarHomeKit(604):
            // change output frequency
            guard let rawValue = newValue as? UInt8 else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            guard let frequency = OutputFrequency(rawValue: UInt(rawValue)) else {
                log?("Invalid frequency \(rawValue)")
                return
            }
            didChange(frequency: frequency)
        default:
            break
        }
    }

    func characteristicListenerDidSubscribe(_ accessory: Accessory,
                                            service: Service,
                                            characteristic: AnyCharacteristic) {
        log?("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") got a subscriber")
    }

    func characteristicListenerDidUnsubscribe(_ accessory: Accessory,
                                              service: Service,
                                              characteristic: AnyCharacteristic) {
        log?("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") lost a subscriber")
    }
    
    func didChangePairingState(from: PairingState, to: PairingState) {
        if to == .notPaired {
            printPairingInstructions()
        }
    }
    
    func printPairingInstructions() {
        if hapDevice.isPaired {
            log?("The device is paired, either unpair using your iPhone or remove the configuration file.")
        } else {
            log?("Scan the following QR code using your iPhone to pair this device:")
            log?(hapDevice.setupQRCode.asText)
        }
    }
}
