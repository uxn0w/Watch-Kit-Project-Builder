//
//  XcodeProjectGenerator.swift
//
//
//  Created by Damian on 18.04.2024.
//

import Foundation
import ZIPFoundation

class XcodeProjectGenerator {
    
    // MARK: Properties
    let name: String
    let templatePath: URL
    let outputProjectPath: String?
    let fileManager: FileManager
    let defaultOutputDirectory: FileManager.SearchPathDirectory
    
    // MARK: - Initializer
    init(
        name: String, 
        templatePath: URL,
        outputProjectPath: String? = nil,
        fileManager: FileManager = FileManager.default,
        defaultOutputDirectory: FileManager.SearchPathDirectory = .documentDirectory
    ) {
        self.name = name
        self.fileManager = fileManager
        self.templatePath = templatePath
        self.outputProjectPath = outputProjectPath
        self.defaultOutputDirectory = defaultOutputDirectory
    }
    
    // MARK: - Methods
    func run() throws {
        let sourceURL = templatePath
        let destinationURL = try createCacheDirectory()
        
        try fileManager.unzipItem(at: sourceURL, to: destinationURL)
        
        try removeZipCache(destinationURL: destinationURL)
        
        let originProjectName = try getOriginProjectName(at: destinationURL)
        
        let projectPath = destinationURL.relativePath + "/\(originProjectName)"

        try XcodeProjectRenamer(newName: name, projectPath: projectPath).run()
        
        try moveProjectFromCacheFolder(projectPath, destinationURL: destinationURL)
    }
    
    func getOriginProjectName(at destinationURL: URL) throws -> String {
        let enumerator = fileManager.enumerator(atPath: destinationURL.relativePath)
        guard let originProjectName = enumerator?.nextObject() as? String else {
            throw "Failure while unwrap origin project name"
        }
        return originProjectName
    }
    
    func getDistinationURL() throws -> URL {
        return try {
            guard let outputProjectPath else {
                return try getDefaultDestinationURL()
            }
            return URL(fileURLWithPath: outputProjectPath)
        }()
    }
    
    func getCacheDirectoryURL() throws -> URL {
        var destinationURL = try getDistinationURL()
        destinationURL.appendPathComponent(".lwp-temp", isDirectory: true)
        return destinationURL
    }
    
    func createCacheDirectory() throws -> URL {
        
        let destinationURL = try getCacheDirectoryURL()
        
        try fileManager.safeRemoveItem(at: destinationURL.relativePath)
        
        try fileManager.createDirectory(
            at: destinationURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return destinationURL
    }
    
    func moveProjectFromCacheFolder(_ projectPath: String, destinationURL: URL) throws {
        var finalDestinationURL = destinationURL
        finalDestinationURL.deleteLastPathComponent()
        finalDestinationURL.appendPathComponent(name, isDirectory: true)
        
        try fileManager.safeRemoveItem(at: finalDestinationURL.relativePath)
        
        try fileManager.moveItem(at: URL(fileURLWithPath: projectPath), to: finalDestinationURL)
        try fileManager.removeItem(at: destinationURL)
    }
    
    func removeZipCache(destinationURL: URL) throws {
        if fileManager.fileExists(atPath: destinationURL.relativePath + "/__MACOSX") {
            var cache = destinationURL
            cache.appendPathComponent("__MACOSX")
            try fileManager.removeItem(at: cache)
        }
    }
    
    func getDefaultDestinationURL() throws -> URL {
        return try fileManager.url(
            for: defaultOutputDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
}
