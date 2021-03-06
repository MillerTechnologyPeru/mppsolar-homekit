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
    
    @Option(default: "/dev/hidraw0", help: "The special file path to the solar device.")
    var path: String
    
    @Option(default: 10, help: "The interval (in seconds) at which data is refreshed.")
    var refreshInterval: Int
    
    @Option(default: "configuration.json", help: "The name of the configuration file.")
    var file: String
    
    @Option(help: "The HomeKit setup code.")
    var setupCode: String?
    
    @Option(default: 8000, help: "The port of the HAP server.")
    var port: UInt
    
    func validate() throws {
        guard refreshInterval >= 1 else {
            throw ValidationError("<refresh-interval> must be at least 1 second.")
        }
    }
    
    func run() throws {
        
        let controller = try SolarController(
            device: path,
            refreshInterval: TimeInterval(refreshInterval),
            fileName: file,
            setupCode: setupCode.map { .override($0) } ?? .random,
            port: port
        )
        
        controller.log = { print($0) }
        controller.printPairingInstructions()
        RunLoop.main.run()
    }
}

MPPSolarHomeKitTool.main()
