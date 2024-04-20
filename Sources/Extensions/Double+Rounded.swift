//
//  Double+Rounded.swift
//
//
//  Created by Damian on 18.04.2024.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
