import Cmpv

func check(error: Int32) {
	if (error < 0) {
		print("mpv API error:", String(cString: mpv_error_string(error)));
		exit(1);
	} else {
		print("OK")
	}
}

var handle = mpv_create()

let loadFile = [Int8]("loadfile".utf8CString)
let radioMaria = [Int8]("http://stream.radiomaria.be/RadioMaria-96.m3u".utf8CString)
let playRadioMaria = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 3)
playRadioMaria[0] = UnsafePointer<Int8>(loadFile)
playRadioMaria[1] = UnsafePointer<Int8>(radioMaria)
playRadioMaria[2] = nil

print(String(cString: playRadioMaria[0]!))
print(String(cString: playRadioMaria[1]!))

check(error: mpv_initialize(handle))

check(error: mpv_command(handle, playRadioMaria))

while true {
	print(mpv_wait_event(handle, 2).pointee.event_id)
}
