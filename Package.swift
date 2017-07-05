// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "ResturauntAPI",
    targets: [
        Target(
            name: "ResturauntServer",
            dependencies: [
                .Target(
                    name: "ResturauntAPI"
                )
            ]
        ),
        Target(
            name: "ResturauntAPI"
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura-CredentialsHTTP", majorVersion: 1, minor: 8),
        .Package(url: "https://github.com/OpenKitten/MongoKitten", majorVersion: 4, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger", majorVersion: 1, minor: 7)
    ]
)
