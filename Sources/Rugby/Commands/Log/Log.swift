//
//  Log.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files
import Foundation

private enum LogError: Error, LocalizedError {
    case cantFindLog

    var errorDescription: String? {
        switch self {
        case .cantFindLog: return "Can't find log."
        }
    }
}

struct Log: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "• Print last command log verbosely."
    )

    func run() throws {
        try WrappedError.wrap(playBell: false) {
            try wrappedRun()
        }
    }
}

extension Log {
    private func wrappedRun() throws {
        guard Folder.current.containsFile(at: .log) else { throw LogError.cantFindLog }
        try printShell("cat " + .log)
    }
}
