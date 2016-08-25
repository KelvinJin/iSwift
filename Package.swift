import PackageDescription

let package = Package(
    name: "iSwift",
    dependencies: [
        .Package(url: "https://github.com/KelvinJin/SwiftZMQ.git", majorVersion: 1),
        .Package(url: "https://github.com/KelvinJin/CommandLine.git", majorVersion: 2),
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 0),
    ]
)
