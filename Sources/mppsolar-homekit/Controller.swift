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
    
    let device: MPPSolar
    
    let refreshInterval: TimeInterval
    
    let accessory: SolarAccessory
    
    var log: ((String) -> ())?
    
    private var refreshTimer: Timer?
    
    public init(device: MPPSolar,
                refreshInterval: TimeInterval) throws {
       
        // Load info
        let serialNumber = try device.send(SerialNumber.Inquiry()).serialNumber
        
        // set values
        self.device = device
        self.refreshInterval = refreshInterval
        self.accessory = SolarAccessory(
            info: Service.Info(
                name: "MPP Solar",
                serialNumber: serialNumber.rawValue,
                manufacturer: "MPP Solar",
                model: "",
                firmwareRevision: ""
            )
        )
        refresh()
        refreshTimer = .scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in self?.refresh() }
    }
    
    func refresh() {
        
        do {
            let mode = try device.send(DeviceMode.Inquiry()).mode
            let status = try device.send(GeneralStatus.Inquiry())
            self.accessory.update(mode: mode, status: status)
        }
        catch { log?("Error: Could not refresh status. \(error)") }
    }
}
