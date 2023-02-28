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
    
    func refresh() {
        
        do {
            try device {
                let protocolID = try $0.send(ProtocolID.Query()).protocolID
                self.accessory.update(protocolID: protocolID)
                let mode = try $0.send(DeviceMode.Query())
                self.accessory.update(mode: mode)
                let serialNumber = try $0.send(SerialNumber.Query()).serialNumber
                self.accessory.update(serial: serialNumber)
                let status = try $0.send(GeneralStatus.Query())
                self.accessory.update(status: status)
                let warning = try $0.send(WarningStatus.Query())
                self.accessory.update(warning: warning)
                let flags = try $0.send(FlagStatus.Query())
                self.accessory.update(flags: flags)
            }
        }
        catch { log?("Error: Could not refresh status. \(error)") }
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
