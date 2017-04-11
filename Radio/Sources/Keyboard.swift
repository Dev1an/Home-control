import InputEvents

var preset: [Key: String] = [
	.f1: rcfBxl,
	.f2: rcfVendee,
	.f3: radioMaria,
	.f4: radioMariaNL,
	.f5: klaraContinuo
]

func couple(remote: String, to radio: Radio) {
	func handleVolume(with keycode: Key, step: Int8 = 10) throws {
		switch keycode {
		case .upArrow:
			try radio.increaseVolume(value: step)
		case .downArrow:
			try radio.decreaseVolume(value: step)
		default:
			break
		}
	}

	do {
		let keyboard = try InputEventCenter(devicePath: remote)
		keyboard.keyPressed = { keycode in
			radioInteraction {
				switch keycode {
				case .escape:
					try radio.stop()
				case .upArrow, .downArrow:
					try handleVolume(with: keycode)
				default:
					if let channel = preset[keycode] {
						try radio.setChannel(to: channel)
					}
				}
			}
		}
		keyboard.keyRepeated = { keycode in
			radioInteraction { try handleVolume(with: keycode, step: 2) }
		}
	} catch KeyboardError.CannotOpen(let fileDescriptor, let reason) {
		print("An error occured while trying to observe the keyboard:")
		print("\t>", "Unable to open the file descriptor", fileDescriptor)
		print("\t>", reason)
	} catch {
		assert(false)
	}
}

func radioInteraction(_ interaction: () throws -> ()) {
	do {
		try interaction()
	} catch RadioError.Mpv(let message) {
		print("Unable to change the radio")
		print(message)
	} catch {
		assert(false)
	}
}
