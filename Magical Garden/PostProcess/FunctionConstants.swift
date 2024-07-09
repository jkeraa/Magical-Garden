//
//  FunctionConstants.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import Foundation

struct FunctionConstants: Hashable {
    var filterIndex: Int
    var time: Float
    
    static func == (lhs: FunctionConstants, rhs: FunctionConstants) -> Bool {
        return lhs.filterIndex == rhs.filterIndex && lhs.time == rhs.time
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(filterIndex)
        hasher.combine(time)
    }
}
