//
//  Check.swift
//  
//
//  Created by mlch911 on 2023/1/9.
//

import ArgumentParser
import Files
import Foundation

struct Check: ParsableCommand {
	@Flag(help: .beta("Use content checksums instead of modification date.\n")) var useContentChecksums = false
	
	static var configuration = CommandConfiguration(
		abstract: "• Check if there is any changes in local Pods. If so, throw an error."
	)
	
	func run() throws {
		try WrappedError.wrap(playBell: false) {
			try CheckStep(command: self).run()
		}
	}
}

struct CheckStep: Step {
	let progress: Printer
	private let checksumsProvider: ChecksumsProvider
	
	init(command: Check) {
		self.progress = RugbyPrinter(title: "Check", verbose: .verbose, quiet: false, nonInteractive: false)
		self.checksumsProvider = ChecksumsProvider(useContentChecksums: command.useContentChecksums)
	}
	
	func run(_ input: Void) throws {
		let cache = CacheManager().load()
		let localPods = try PodsProvider.shared.localPods()
		guard let checksums = cache?.values.first?.checksumsMap() else { return }
		let localPodsChecksums = try progress.spinner("Calculate checksums") {
			try checksumsProvider.getChecksums(forPods: Set(localPods.map(\.name)))
		}
		let changedPods = localPodsChecksums.filter { checksums[$0.name] != nil && checksums[$0.name]?.value != $0.value }
		if changedPods.isEmpty {
			progress.print("[Check Passed]")
			done()
		} else {
			progress.print("[Check Failed] Found changed Pod: \(changedPods) in Cache.")
			throw CheckError.checkFail
		}
	}
}

extension Dictionary.Values {
	func array() -> [Element] {
		Array(self)
	}
}

enum CheckError: Error {
	case checkFail
}
