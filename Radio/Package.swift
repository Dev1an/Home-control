import PackageDescription

let package = Package(
    name: "Radio",
    dependencies: [
		.Package(url: "../Cmpv", majorVersion: 0)
	]
)
