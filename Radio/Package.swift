import PackageDescription

let package = Package(
    name: "Radio",
    dependencies: [
		.Package(url: "https://github.com/Dev1an/Cmpv.git", majorVersion: 1)
	]
)
