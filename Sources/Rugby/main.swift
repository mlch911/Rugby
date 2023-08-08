import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """

        🏈 Cache CocoaPods for faster rebuild and indexing Xcode project.
        📖 \("https://github.com/swiftyfinch/Rugby".cyan)
        (⌘ + double click on the link)
        """,
        version: "1.30.6",
        subcommands: [
            Plans.self,
            Cache.self,
            Focus.self,
            Drop.self,
            Rollback.self,
            Log.self,
            Doctor.self,
            Clean.self,
			Check.self,
        ],
        defaultSubcommand: Plans.self
    )
}

ProcessMonitor.sync()
Rugby.main()
