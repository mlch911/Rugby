//
//  PBXTarget+RecursiveDependencies.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTarget {
    func recursiveDependencies(used: [String: PBXTargetDependency] = [:]) -> [String: PBXTargetDependency] {
        var used = used
        for dependency in dependencies {
            guard let name = dependency.displayName, used[name] == nil else { continue }
            used[name] = dependency
            if let names = dependency.target?.recursiveDependencies(used: used) {
                used.merge(names, uniquingKeysWith: { lhs, _ in lhs })
            }
        }
        return used
    }
}
