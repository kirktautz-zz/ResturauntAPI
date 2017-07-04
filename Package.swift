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
                ),
                .Target(
                    name: "UsersAPI"
                )
            ]
        ),
        Target(
            name: "ResturauntAPI"
        ),
        Target(
            name: "UsersAPI"
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura-Credentials", majorVersion: 1, minor: 7),
        
        .Package(url: "https://github.com/OpenKitten/MongoKitten", majorVersion: 4, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger", majorVersion: 1, minor: 7)
    ]
)
