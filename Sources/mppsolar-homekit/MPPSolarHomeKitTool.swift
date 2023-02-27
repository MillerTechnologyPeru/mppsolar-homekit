#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation
import MPPSolar
import HAP
import ArgumentParser

@main
struct MPPSolarHomeKitTool: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "A deamon for exposing an MPP Solar device to HomeKit",
        version: "1.0.0"
    )
    
    @Option(help: "The special file path to the solar device.")
    var path: String = "/dev/hidraw0"
    
    @Option(help: "The interval (in seconds) at which data is refreshed.")
    var refreshInterval: Int = 10
    
    @Option(help: "The name of the configuration file.")
    var file: String = "configuration.json"
    
    @Option(help: "The HomeKit setup code.")
    var setupCode: String?
    
    @Option(help: "The port of the HAP server.")
    var port: UInt = 8000
    
    @Option(help: "The model of the solar inverter.")
    var model: String = "PIP-2424LV-MSD"
    
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
            port: port,
            model: model
        )
        
        controller.log = { print($0) }
        controller.printPairingInstructions()
        RunLoop.main.run()
    }
}
