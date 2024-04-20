//
//  Generator.swift
//
//
//  Created by Damian on 18.04.2024.
//

import ArgumentParser
import Foundation

struct Generate: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "Generate Legacy WatchOS project",
        subcommands: []
    )
    
    @Argument(help: "Project name")
    var name: String
    
    @Argument(help: "Destination of the output project; By default: Documents dir")
    var outputPath: String? = nil
    
    mutating func run() throws {        
        try TimeMeasure { time in
            let templatePath = try getTemplateProjectPathURL()
            
            let generator = XcodeProjectGenerator(
                name: name,
                templatePath: templatePath,
                outputProjectPath: outputPath,
                defaultOutputDirectory: .documentDirectory
            )
            
            try generator.run()
            print("\(name) generated! Time: \(time()) sec.")
        }
    }
    
    func getTemplateProjectPathURL() throws -> URL {
        let path = Bundle.module.url(
            forResource: "1",
            withExtension: "zip",
            subdirectory: "Resources"
        )
        guard let path else {
            throw "Error: Template file not found"
        }
        return path
    }
}
