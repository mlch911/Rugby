//
//  CacheHeader.swift
//  
//
//  Created by v.khorkov on 29.01.2021.
//

import ArgumentParser
import Rainbow

struct Cache: ParsableCommand {
    @Option(name: .shortAndLong, help: "Build architechture.") var arch: String?
    @Option(name: .shortAndLong, help: "Build sdk: sim or ios.") var sdk: SDK = .sim
    @Flag(name: .shortAndLong, help: "Keep Pods group in project.") var keepSources = false
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Exclude pods from cache.") var exclude: [String] = []
    @Flag(help: "Hide metrics.") var hideMetrics = false
    @Flag(help: "Ignore already cached pods checksums.") var ignoreCache = false
    @Flag(help: "Skip building parents of changed pods.\n") var skipParents = false

    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    static var configuration: CommandConfiguration = .init(
        abstract: "Convert remote pods to prebuilt dependencies."
    )

    func run() throws {
        try WrappedError.wrap(wrappedRun)
    }
}