//
//  TimeMeasure.swift
//
//
//  Created by Damian on 18.04.2024.
//

import Foundation

func TimeMeasure(block: (@escaping () -> Double) throws -> Void) rethrows {
    
    let startTime = DispatchTime.now().uptimeNanoseconds
    
    try block {
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1e9
        return timeElapsed.rounded(toPlaces: 2)
    }
}
