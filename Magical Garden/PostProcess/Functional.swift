//
//  Functional.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import Foundation

public protocol FunctionalWrapper {}

extension NSObject: FunctionalWrapper {}

public extension FunctionalWrapper {
    func `do`(_ mutator: (Self) -> Void) -> Self {
        mutator(self)
        return self
    }
}
