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
    
    @Argument(default: "configuration.json", help: "The name of the configuration file.")
    var file: String
    
    @Argument(default: nil, help: "The HomeKit setup code.")
    var setupCode: String?
    
    @Argument(default: 8000, help: "The port of the HAP server.")
    var port: UInt
    
    func validate() throws {
        guard refreshInterval >= 1 else {
            throw ValidationError("<refresh-interval> must be at least 1 second.")
        }
    }
    
    func run() throws {
        
        print("Loading solar device at \(path)...")
        
        guard let solarDevice = MPPSolar(path: path)
            else { throw CommandError.deviceUnavailable }
        
        let controller = try SolarController(
            device: solarDevice,
            refreshInterval: TimeInterval(refreshInterval),
            fileName: file,
            setupCode: setupCode.map { .override($0) } ?? .random,
            port: port
        )
        
        controller.log = { print($0) }
        
        RunLoop.main.run()
    }
}

MPPSolarHomeKitTool.main()
