#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation
import MPPSolar
import HAP
import ArgumentParser

struct MPPSolarHomeKitTool: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "A deamon for exposing an MPP Solar device to HomeKit",
        version: "1.0.0"
    )
    
    @Argument(default: "/dev/hidraw0", help: "The special file path to the solar device.")
    var path: String
    
    @Argument(default: 10, help: "The interval (in seconds) at which data is refreshed.")
    var refreshInterval: Int
    
    func validate() throws {
        guard refreshInterval >= 1 else {
            throw ValidationError("")
        }
    }
            
    func run() throws {
        
        print("Loading solar device at \(path)...")
        
        guard let solarDevice = MPPSolar(path: path)
            else { throw CommandError.deviceUnavailable }
        
        let controller = try SolarController(device: solarDevice, refreshInterval: TimeInterval(refreshInterval))
        
        controller.log = { print($0) }
        
        RunLoop.main.run()
    }
}

MPPSolarHomeKitTool.main()
