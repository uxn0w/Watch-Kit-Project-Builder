//
//  XcodeProjectRenamer.swift
//
//
//  Created by Damian on 18.04.2024.
//

import Foundation

class XcodeProjectRenamer: NSObject {
    
    // MARK: Properties
    private let fileManager = FileManager.default
    
    let newName: String
    let projectPath: String
    private var processedPaths = [String]()
    
    // MARK: - Initializer
    init(newName: String, projectPath: String) {
        self.newName = newName
        self.projectPath = projectPath
    }
    
    // MARK: - Methods
    func run() throws {
        let previousName = try self.getPreviousName(from: projectPath)

        if self.validatePath(projectPath, previousName: previousName) {
            self.processPaths(projectPath, previousProjectName: previousName)
        } else {
            throw "Error: Xcode project or workspace with name: [\(previousName)] is not found at current path."
        }
        self.processedPaths = []
    }
}

// MARK: - Private
private extension XcodeProjectRenamer {
    
    func getPreviousName(from projectPath: String) throws -> String {
        
        let enumerator = FileManager.default.enumerator(atPath: projectPath)
        
        while let element = enumerator?.nextObject() as? String {
            let filePath = (element as NSString)
            if filePath.pathExtension == "xcodeproj" {
                return String(filePath.deletingPathExtension)
            }
        }
        
        throw "Previous name not found"
    }
    
    func validatePath(_ path: String, previousName: String) -> Bool {
        let projectPath = path.appending("/\(previousName).xcodeproj")
        let workspacePath = path.appending("/\(previousName).xcworkspace")
        let isValid = self.fileManager.fileExists(atPath: projectPath) || self.fileManager.fileExists(atPath: workspacePath)
        return isValid
    }
    
    func processPaths(_ path: String, previousProjectName: String) {
        let enumerator = self.fileManager.enumerator(atPath: path)
        
        while let element = enumerator?.nextObject() as? String {
            let itemPath = path.appending("/\(element)")
            
            if !self.processedPaths.contains(itemPath) && !shouldSkip(element) {
                self.processPath(itemPath, previousProjectName: previousProjectName)
            }
        }
    }
    
    func processPath(_ path: String, previousProjectName: String) {
        
        var isDir: ObjCBool = false
        
        if self.fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                self.processPaths(path, previousProjectName: previousProjectName)
            } else {
                self.updateFileContent(atPath: path, previousProjectName: previousProjectName)
            }
            self.renameItem(atPath: path, previousProjectName: previousProjectName)
        }
        self.processedPaths.append(path)
    }
    
    func shouldSkip(_ element: String) -> Bool {
        guard
            !element.hasPrefix("."),
            !element.contains(".DS_Store"),
            !element.contains("Carthage"),
            !element.contains("Pods"),
            !element.contains("fastlane"),
            !element.contains("build")
        else { return true }
        
        let fileExtension = URL(fileURLWithPath: element).pathExtension
        
        switch fileExtension {
        case "appiconset", "json", "png", "xcuserstate":
            return true
        default:
            return false
        }
    }
    
    func updateFileContent(atPath path: String, previousProjectName: String) {
        do {
            let originContent = try String(contentsOfFile: path, encoding: .utf8)
            
            if originContent.contains(previousProjectName) {
                let newContent = originContent.replacingOccurrences(
                    of: previousProjectName,
                    with: self.newName
                )
                try newContent.write(toFile: path, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error: Failure while updating file: \(error.localizedDescription)\n")
        }
    }
    
    func renameItem(atPath path: String, previousProjectName: String) {
        do {
            let oldItemName = URL(fileURLWithPath: path).lastPathComponent
            
            if oldItemName.contains(previousProjectName) {
                let newItemName = oldItemName.replacingOccurrences(
                    of: previousProjectName,
                    with: newName
                )
                let directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
                let newPath = directoryURL.appendingPathComponent(newItemName).path
                try fileManager.moveItem(atPath: path, toPath: newPath)
            }
        } catch {
            print("Failure while renaming file: \(error.localizedDescription)")
        }
    }
}
