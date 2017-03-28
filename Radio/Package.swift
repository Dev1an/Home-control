import PackageDescription

let package = Package(
    name: "Home control",
    dependencies: [
		.Package(url: "../Cmpv", majorVersion: 0)
	]
)
