import PackageDescription

let package = Package(
    name: "iSwift",
    dependencies: [
        .Package(url: "https://github.com/Zewo/ZeroMQ.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor.git", majorVersion: 0),
        .Package(url: "https://github.com/DanToml/Jay.git", majorVersion: 1),
        .Package(url: "https://github.com/jatoben/CommandLine", Version(3, 0, 0, prereleaseIdentifiers: ["pre"])),
        .Package(url: "https://github.com/jensravens/interstellar.git", majorVersion: 2),
        .Package(url: "https://github.com/KelvinJin/SourceKitten.git", "0.17.1")
    ]
)
