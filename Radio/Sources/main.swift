import Cmpv
import InputEvents
import Dispatch

func check(error: Int32, message: String? = nil) {
	if (error < 0) {
		print("mpv API error:", String(cString: mpv_error_string(error)));
		exit(1);
	} else if let message = message {
		print(message)
	}
}

var handle = mpv_create()

let loadFile = [Int8]("loadfile".utf8CString)
let radioMaria = [Int8]("http://stream.radiomaria.be/RadioMaria-96.m3u".utf8CString)
let klaraContinuo = [Int8]("http://mp3.streampower.be/klaracontinuo-mid.mp3".utf8CString)
let playURL = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 3)
playURL[0] = UnsafePointer<Int8>(loadFile)
playURL[1] = UnsafePointer<Int8>(radioMaria)
playURL[2] = nil

check(error: mpv_initialize(handle), message: "Initialising mpv")
check(error: mpv_command(handle, playURL), message: "Play radio maria")

print("starting keyboard observer")

if let keyboard = try? InputEventCenter(devicePath: "/dev/input/event2") {
	keyboard.keyPressed = { keycode in
		print("keyboard: ", keycode, "pressed")
		if keycode == 60 || keycode == 61 {
			if keycode == 60 {
				playURL[1] = UnsafePointer<Int8>(radioMaria)
			} else {
				playURL[1] = UnsafePointer<Int8>(klaraContinuo)
			}
			check(error: mpv_command(handle, playURL))
		}
	}
}

print("\n")
print("- - - - - - - - - - - - - - - - - -")
print("Command line internet radio player\n")
print("\tPress F2 for Radio Maria")
print("\tPress F3 for Klara Continuo")
print("- - - - - - - - - - - - - - - - - -")
print("\n")


while true {
	let eventID = mpv_wait_event(handle, Double.greatestFiniteMagnitude).pointee.event_id.rawValue
	print("mpv:", Event(rawValue: eventID) ?? "Unknown event")
}
