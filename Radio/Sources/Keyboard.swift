import InputEvents

let rcfBxl = "http://rcf.streamakaci.com/rcfbruxelles.mp3"
let rcfVendee = "http://rcf.streamakaci.com/rcf85.mp3"
let radioMaria = "http://stream.radiomaria.be/RadioMaria-96.m3u"
let klaraContinuo = "http://mp3.streampower.be/klaracontinuo-high.mp3"

func couple(remote: String, to radio: Radio) {
	func handleVolume(with keycode: UInt16) throws {
		switch keycode {
		case 103:
			try radio.increaseVolume(value: 10)
		case 108:
			try radio.decreaseVolume(value: 10)
		default:
			break
		}
	}

	do {
		print("trying to start keyboard observer")
		let keyboard = try InputEventCenter(devicePath: remote)
		keyboard.keyPressed = { keycode in
			radioInteraction {
				switch keycode {
				case 59:
					try radio.setChannel(to: rcfBxl)
				case 60:
					try radio.setChannel(to: rcfVendee)
				case 61:
					try radio.setChannel(to: radioMaria)
				case 63:
					try radio.setChannel(to: klaraContinuo)
				case 14:
					try radio.stop()
				default:
					try handleVolume(with: keycode)
				}
			}
		}
		keyboard.keyRepeated = { keycode in
			radioInteraction { try handleVolume(with: keycode) }
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
