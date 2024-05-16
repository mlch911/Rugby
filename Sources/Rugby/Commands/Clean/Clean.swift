//
//  Clean.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files
import Yams

struct Clean: ParsableCommand, Command {
	var quiet: Bool = false
	var nonInteractive: Bool = false
	
	@Option(name: .shortAndLong, help: "Local Cache Location. Default remove all. Split with ','")
	var pods: String = ""
	
    static var configuration = CommandConfiguration(
        abstract: "• Remove cache except \("plans.yml".yellow) and logs."
    )

    func run() throws {
        try WrappedError.wrap(playBell: false) {
			let pods = pods
				.split(separator: ",")
				.map { String($0) }
				.filter { !$0.isEmpty }
			try CleanStep(pods: pods).run()
        }
    }
	
	mutating func run(logFile: Files.File) throws -> Metrics? {
		try run()
		return nil
	}
}

// MARK: - CleanStep

struct CleanStep: Step {
    let isLast = true
    let progress: Printer
	
	var pods: [String]

    init(pods: [String]) {
        self.progress = RugbyPrinter(title: "Clean", verbose: .verbose, quiet: false, nonInteractive: false)
		self.pods = pods
    }

    func run(_ input: Void) throws {
		try deleteCacheMap()
		deleteBuildCache()
        done()
    }
	
	private func deleteCacheMap() throws {
		if pods.isEmpty {
			// Delete All Cache Map
			let filesForDelete: [String] = [.cacheFile]
			filesForDelete.forEach {
				if Folder.current.deleteFileIfExists(at: $0) {
					progress.print("Removed \($0)".yellow)
				}
			}
		} else {
			// Delete Specific Cache
			let cacheManager = CacheManager()
			try pods.forEach { pod in
				let sdks: [SDK] = [.ios, .sim]
				for sdk in sdks {
					var checksums = cacheManager.checksumsMap(sdk: sdk, config: CONFIG.debug)
					guard checksums[pod] != nil else { return }
					checksums[pod] = nil
					let newChecksums = checksums.map(\.value.string).sorted()
					guard let cache = cacheManager.load(sdk: sdk, config: CONFIG.debug) else { return }
					let newCache = BuildCache(sdk: cache.sdk,
											  arch: cache.arch,
											  config: cache.config,
											  swift: cache.swift,
											  xcargs: cache.xcargs,
											  checksums: newChecksums)
					try cacheManager.update(cache: newCache)
					progress.print("Removed \(pod) cache checksum".yellow)
				}
			}
		}
	}
	
	private func deleteBuildCache() {
		if pods.isEmpty {
			// Delete All Cache
			if Folder.current.deleteSubfolderIfExists(at: .buildFolder) {
				progress.print("Removed \(String.buildFolder)".yellow)
			}
		} else {
			pods.forEach {
				deleteBuildCache(pod: $0)
			}
		}
	}
	
	private func deleteBuildCache(pod: String) {
		let sdks: [SDK] = [.ios, .sim]
		let archs: [ARCH] = [.arm64, .generic]
		for (sdk, arch) in zip(sdks, archs) {
			let fakeCache = BuildCache(sdk: sdk,
									   arch: arch.rawValue,
									   config: CONFIG.debug,
									   swift: SwiftVersionProvider().swiftVersion(),
									   xcargs: nil,
									   checksums: nil)
			let cacheKey = fakeCache.cacheKeyName()
			
			func deletePodFolder(in folder: Folder, podFolderSuffix: String = "") {
				let podFolderName = pod + podFolderSuffix
				if let cacheFolder = try? folder.subfolder(named: cacheKey), cacheFolder.containsSubfolder(named: podFolderName) {
					if cacheFolder.deleteSubfolderIfExists(at: podFolderName) {
						progress.print("Removed \(podFolderName) build folder".yellow)
					}
				}
			}
			
			guard let buildFolder = try? Folder(path: .buildFolder) else { return }
			deletePodFolder(in: buildFolder)
			guard let pod_build_folder = try? buildFolder.subfolder(named: "Pods.build") else { return }
			deletePodFolder(in: pod_build_folder, podFolderSuffix: ".build")
			deletePodFolder(in: pod_build_folder, podFolderSuffix: "-\(pod)Resource.build")
		}
	}
}
