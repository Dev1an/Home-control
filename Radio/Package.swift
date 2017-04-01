import PackageDescription

let package = Package(
    name: "Radio",
    dependencies: [
		.Package(url: "https://github.com/Dev1an/Cmpv",  majorVersion: 1),
		.Package(url: "https://github.com/Dev1an/InputEvents",  majorVersion: 1),
		.Package(url: "https://github.com/Dev1an/EventSource.git", majorVersion: 1)
	]
)
