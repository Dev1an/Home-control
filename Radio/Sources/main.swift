import Cmpv

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
let playRadioMaria = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 3)
playRadioMaria[0] = UnsafePointer<Int8>(loadFile)
playRadioMaria[1] = UnsafePointer<Int8>(radioMaria)
playRadioMaria[2] = nil

check(error: mpv_initialize(handle), message: "Initialising mpv")
check(error: mpv_command(handle, playRadioMaria), message: "Play radio maria")

while true {
	let eventID = mpv_wait_event(handle, Double.greatestFiniteMagnitude).pointee.event_id.rawValue
	print(Event(rawValue: eventID) ?? "Unknown event")
}
