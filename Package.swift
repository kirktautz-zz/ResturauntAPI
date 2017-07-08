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
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/kirktautz/KTD-Kitura-CredentialsJWT.git", majorVersion: 1),
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 4, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 7)
    ]
)
