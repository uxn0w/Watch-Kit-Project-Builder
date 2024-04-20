//
//  Rename.swift
//
//
//  Created by Damian on 18.04.2024.
//

import ArgumentParser

struct Rename: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "Rename XCode project",
        subcommands: []
    )
    
    @Argument(help: "Project path") var projectPath: String
    @Argument(help: "New project name") var newName: String
    
    mutating func run() throws {
        try TimeMeasure { time in
            let renamer = XcodeProjectRenamer(
                newName: newName,
                projectPath: projectPath
            )
            try renamer.run()
            print("New project name: \(newName)! Time: \(time()) sec.")
        }
    }
}

