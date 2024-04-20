//
//  String+LocalizedError.swift
//
//
//  Created by Damian on 19.04.2024.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
