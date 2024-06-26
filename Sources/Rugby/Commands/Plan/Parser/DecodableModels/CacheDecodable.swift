//
//  CacheDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct CacheDecodable: Decodable {
    let arch: [String]?
    let config: String?
    let sdk: [SDK]?
    let bitcode: Bool?
    let keepSources: Bool?
    let exclude: [String]?
    let ignoreChecksums: Bool?
    let useContentChecksums: Bool?
    let include: [String]?
    let focus: [String]?
    let graph: Bool?
    let offDebugSymbols: Bool?
    let useRelativePaths: Bool?
	let retryCount: Int?
	let onlyRetryFailureString: [String]?
	
	let bell: Bool?
    let hideMetrics: Bool?
    @BoolableIntDecodable var verbose: Int?
    let quiet: Bool?
    let nonInteractive: Bool?
    let ignoreGitDirtyLocalPods: Bool?
}

extension Cache {
    init(from decodable: CacheDecodable) {
        self.arch = decodable.arch ?? []
        self.config = decodable.config ?? CONFIG.debug
        self.sdk = decodable.sdk ?? [.sim]
        self.bitcode = decodable.bitcode ?? false
        self.keepSources = decodable.keepSources ?? false
        self.exclude = decodable.exclude ?? []
        self.ignoreChecksums = decodable.ignoreChecksums ?? false
        self.useContentChecksums = decodable.useContentChecksums ?? false
        self.include = decodable.include ?? []
        self.focus = decodable.focus ?? []
        self.graph = decodable.graph ?? true
        self.offDebugSymbols = decodable.offDebugSymbols ?? false
        self.useRelativePaths = decodable.useRelativePaths ?? false
        self.ignoreGitDirtyLocalPods = decodable.ignoreGitDirtyLocalPods ?? false
		self.retryCount = decodable.retryCount ?? 0
		self.onlyRetryFailureString = decodable.onlyRetryFailureString ?? []

        self.flags = .init()
        self.flags.bell = decodable.bell ?? true
        self.flags.hideMetrics = decodable.hideMetrics ?? false
        self.flags.verbose = decodable.verbose ?? 0
        self.flags.quiet = decodable.quiet ?? false
        self.flags.nonInteractive = decodable.nonInteractive ?? false
    }
}
