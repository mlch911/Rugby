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
	static var configuration = CommandConfiguration(
		abstract: "• Remove cache except \("plans.yml".yellow) and logs."
	)
	
	func run() throws {
		try WrappedError.wrap(playBell: false) {
			try CheckStep().run()
		}
	}
}

struct CheckStep: Step {
	let progress: Printer
	
	init() {
		self.progress = RugbyPrinter(title: "Check", verbose: .verbose, quiet: false, nonInteractive: false)
	}
	
	func run(_ input: Void) throws {
		let cache = CacheManager().load()
		let changedPods = try PodsProvider.shared.localPods()
			.filter { !$0.isGitClean }
		guard let pods = try cache?.values.first?.checksums?
			.compactMap({ text -> (String, NSTextCheckingResult)? in
				guard let result = try ".*(?=:\\ )".regex().firstMatch(text) else { return nil }
				return (text, result)
			}).map({ ($0.0 as NSString).substring(with: $0.1.range) }) else {
			done()
			return
		}
		if let pod = pods.first(where: changedPods.map(\.name).contains) {
			progress.print("[Check Failed] Found changed Pod: \(pod) in Cache.")
			throw CheckError.checkFail
		} else {
			progress.print("[Check Passed]")
			done()
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
