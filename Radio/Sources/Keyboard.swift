import InputEvents

var preset: [UInt16: String] = [
	59: rcfVendee,
	60: radioMaria,
	61: radioMariaNL,
	62: klaraContinuo,
	63: radioCourtoisie,
	64: rcfBxl
]

func couple(remote: String, to radio: Radio) {
	func handleVolume(with keycode: UInt16, step: Int8 = 10) throws {
		switch keycode {
		case 103:
			try radio.increaseVolume(value: step)
		case 108:
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
				case 14:
					try radio.stop()
				case 103, 108:
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
