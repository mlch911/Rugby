//
//  RollbackDecodable.swift
//  
//
//  Created by mlch911 on 2023/1/9.
//

import Foundation

struct RollbackDecodable: Decodable {
    @BoolableIntDecodable var verbose: Int?
    let quiet: Bool?
    let nonInteractive: Bool?
}

extension Rollback {
    init(from decodable: RollbackDecodable) {
        self.verbose = decodable.verbose ?? 0
        self.quiet = decodable.quiet ?? false
        self.nonInteractive = decodable.nonInteractive ?? false
    }
}
