import PackageDescription

let package = Package(
    name: "iSwift",
    dependencies: [
        .Package(url: "https://github.com/KelvinJin/SwiftZMQ.git", majorVersion: 1),
        .Package(url: "https://github.com/jatoben/CommandLine.git", majorVersion: 2),
    ]
)
