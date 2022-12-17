// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Preferences",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .library(
      name: "Preferences",
      targets: [
        "Preferences"
      ]
    )
  ],
  targets: [
    .target(
      name: "Preferences"
    )
  ]
)
