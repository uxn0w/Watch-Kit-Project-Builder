//
//  FileManager+Safe.swift
//
//
//  Created by Damian on 19.04.2024.
//

import Foundation

extension FileManager {
    func safeRemoveItem(at path: String) throws {
        if self.fileExists(atPath: path) {
            try self.removeItem(atPath: path)
        }
    }
}
