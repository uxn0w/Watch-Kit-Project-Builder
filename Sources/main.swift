//
//  main.swift
//
//
//  Created by Damian on 18.04.2024.
//


import ArgumentParser

struct WKProject: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command line tool for creating an old-style Watch OS XCode project",
        version: "0.0.1",
        subcommands: [Rename.self, Generate.self])
}

WKProject.main()
