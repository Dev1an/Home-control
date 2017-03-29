import Cmpv
import InputEvents

let device: String
if CommandLine.arguments.count > 1 { device = CommandLine.arguments[1] }
else { device = "/dev/input/by-id/usb-flirc.tv_flirc-if01-event-kbd" }

do {
	let radio = try Radio()
	
	let radioMaria = "http://stream.radiomaria.be/RadioMaria-96.m3u"
	let klaraContinuo = "http://mp3.streampower.be/klaracontinuo-high.mp3"
	
	do {
		try radio.setChannel(to: radioMaria)
	} catch RadioError.Mpv(let message) {
		print("Unable to play radio maria")
	}
	
	do {
		print("trying to start keyboard observer")
		let keyboard = try InputEventCenter(devicePath: device)
		keyboard.keyPressed = { keycode in
			do {
				switch keycode {
				case 60:
					try radio.setChannel(to: klaraContinuo)
				case 61:
					try radio.setChannel(to: radioMaria)
				case 14:
					try radio.stop()
				default:
					print("key with code \(keycode) was pressed, but not assigned to an action")
				}
			} catch RadioError.Mpv(let message) {
				print("Unable to change the radio")
				print(message)
			} catch {
				assert(false)
			}
		}
	} catch KeyboardError.CannotOpen(let fileDescriptor, let reason) {
		print("An error occured while trying to observer the keyboard")
		print("Unable to open the file descriptor", fileDescriptor)
		print(reason)
	}
	
} catch RadioError.Mpv(let message) {
	print("Unable to initialise radio")
	print(message)
}

print("\n")
print("- - - - - - - - - - - - - - - - - -")
print("Command line internet radio player\n")
print("\tPress F2 for Radio Maria")
print("\tPress F3 for Klara Continuo")
print("- - - - - - - - - - - - - - - - - -")
print("\n")

import Dispatch
dispatchMain()
