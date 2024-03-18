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
        
    private let filePath: String
    
    private let accessory: SolarInverterAccessory
    
    private let hapDevice: HAP.Device
    
    private let server: HAP.Server
    
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    public init(
        device path: String,
        fileName: String,
        setupCode: HAP.Device.SetupCode,
        port: UInt,
        model: String
    ) async throws {
        
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
        self.accessory = accessory
        self.hapDevice = hapDevice
        self.server = try HAP.Server(device: hapDevice, listenPort: Int(port))
        self.hapDevice.delegate = self
        // refresh info once
        try await device {
            try await refresh($0)
        }
    }
    
    // MARK: - Methods
    
    private func device<T>(_ block: (MPPSolar) async throws -> (T)) async throws -> T {
        guard let device = await MPPSolar(path: filePath)
            else { throw CommandError.deviceUnavailable }
        return try await block(device)
    }
    
    private func refresh(_ device: MPPSolar) async throws {
        let status = try await device.send(GeneralStatus.Query())
        self.accessory.update(status: status)
        let protocolID = try await device.send(ProtocolID.Query()).protocolID
        self.accessory.update(protocolID: protocolID)
        let mode = try await device.send(DeviceMode.Query())
        self.accessory.update(mode: mode)
        let serialNumber = try await device.send(SerialNumber.Query()).serialNumber
        self.accessory.update(serial: serialNumber)
        let warning = try await device.send(WarningStatus.Query())
        self.accessory.update(warning: warning)
        let flags = try await device.send(FlagStatus.Query())
        self.accessory.update(flags: flags)
        let firmwareVersion = try await device.send(FirmwareVersion.Query()).version
        self.accessory.update(firmware: firmwareVersion)
        let firmwareVersion2 = try await device.send(FirmwareVersion.Query.Secondary()).version
        self.accessory.update(secondary: firmwareVersion2)
        let rating = try await device.send(DeviceRating.Query())
        self.accessory.update(rating: rating)
    }
    
    func refresh() async {
        await refreshTask?.value // wait for last task
        refreshTask = Task {
            do {
                try await device {
                    try await refresh($0)
                }
            }
            catch { log?("Error: Could not refresh device information. \(error)") }
        }
    }
    
    func didChange(flag: FlagStatus, newValue: Bool) async {
        do {
            let setting: FlagStatus.Setting = newValue ? .init(enabled: [flag]) : .init(disabled: [flag])
            try await device {
                let _ = try await $0.send(setting)
                log?("\(newValue ? "Enabled" : "Disabled") \(flag.description)")
            }
        }
        catch { log?("Error: Could not set \(flag.description). \(error)") }
        
        try? await Task.sleep(timeInterval: 1.0)
        await refresh()
    }
    
    func didChange(frequency: OutputFrequency) async {
        do {
            try await device {
                let _ = try await $0.send(OutputFrequency.Setting(frequency: frequency))
                log?("Set output frequency to \(frequency)")
            }
        }
        catch { log?("Error: Could not set output frequency to \(frequency). \(error)") }
        try? await Task.sleep(timeInterval: 2.0)
        await refresh()
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
            Task {
                await didChange(flag: .buzzer, newValue: value)
            }
        case .solarFlag(.overloadBypass):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .overloadBypass, newValue: value)
            }
        case .solarFlag(.powerSaving):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .powerSaving, newValue: value)
            }
        case .solarFlag(.displayTimeout):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .displayTimeout, newValue: value)
            }
        case .solarFlag(.overloadRestart):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .overloadRestart, newValue: value)
            }
        case .solarFlag(.temperatureRestart):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .temperatureRestart, newValue: value)
            }
        case .solarFlag(.backlight):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .backlight, newValue: value)
            }
        case .solarFlag(.alarm):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .alarm, newValue: value)
            }
        case .solarFlag(.recordFault):
            guard let value = newValue as? Bool else {
                assertionFailure("invalid type \(String(describing: newValue))")
                return
            }
            Task {
                await didChange(flag: .recordFault, newValue: value)
            }
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
            Task {
                await didChange(frequency: frequency)
            }
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
