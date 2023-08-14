//
//  CacheRun.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

extension Cache: Command {
    var quiet: Bool { flags.quiet }
    var nonInteractive: Bool { flags.nonInteractive }

    mutating func run(logFile: File) throws -> Metrics? {
        if !arch.isEmpty, sdk.count != arch.count { throw CacheError.incorrectArchCount }
        if arch.isEmpty { arch = sdk.map(\.defaultARCH) /* Set default arch for each sdk */ }
        arch = zip(sdk, arch).map { s, a in
            if s == .sim, a == "auto" {
				return machineArchitecture() ?? ARCH.x86_64.rawValue
            }
            return a
        }

        // For build configuration name use Debug by default.
        if config == nil { config = CONFIG.debug }

        let metrics = CacheMetrics(project: String.podsProject.basename())
        let factory = CacheStepsFactory(command: self, metrics: metrics, logFile: logFile)
		let work = {
			let info = try factory.prepare(.buildTarget)
			try factory.build(.init(scheme: info.scheme, buildInfo: info.buildInfo, swift: info.swiftVersion))
			try factory.integrate(info.targets)
			try factory.cleanup(.init(scheme: info.scheme, targets: info.targets, products: info.products))
		}
		
		if retryCount > 0 {
			let logger = RugbyPrinter(formatter: RugbyFormatter(title: "Cache_Retry"),
						 screenPrinters: quiet ? [] : [DefaultPrinter(verbose: flags.verbose)],
						 logPrinters: [FilePrinter(file: logFile)],
						 spinnerMode: quiet ? .quiet : nonInteractive ? .simple : .standard)
			var count = 0
			while count <= retryCount {
				do {
					try work()
					break
				} catch {
					if !onlyRetryFailureString.isEmpty,
					   onlyRetryFailureString.first(where: {
						   error.beautifulDescription.contains($0)
					   }) == nil {
						throw error
					}
					logger.print(error.beautifulDescription, level: 1)
					count += 1
					if count > retryCount {
						throw error
					} else {
						logger.print("Retry: \(count)/\(retryCount)".red, level: 1)
					}
				}
			}
		} else {
			try work()
		}
        
        return metrics
    }
}
