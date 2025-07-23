// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownTextView",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MarkdownTextView",
            targets: ["MarkdownTextView"]),
    ],
    targets: [
        .target(
            name: "MarkdownTextView"),
        .testTarget(
            name: "MarkdownTextViewTests",
            dependencies: ["MarkdownTextView"]
        ),
    ]
)
