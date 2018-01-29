import InputEvents

var preset: [Key: String] = [
	.f1: rcfVendee,
	.f2: radioMaria,
	.f3: radioMariaNL,
	.f4: klaraContinuo,
	.f5: radioCourtoisie,
	.f6: rcfBxl
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
		keyboard.keyPressed = { key in
			radioInteraction {
				switch key {
				case .escape:
					try radio.stop()
				case .space:
					try radio.pause()
				case .upArrow, .downArrow:
					try handleVolume(with: key)
				default:
					if let channel = preset[key] {
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
