import Cmpv
import Dispatch

let rcfBxl = "http://rcf.streamakaci.com/rcfbruxelles.mp3"
let rcfVendee = "http://rcf.streamakaci.com/rcf85.mp3"
let radioMaria = "http://stream.radiomaria.be/RadioMaria-96.m3u"
let radioMariaNL = "http://87.233.180.73:8000/listen.pls"
let klaraContinuo = "http://mp3.streampower.be/klaracontinuo-high.mp3"
let radioCourtoisie = "http://www.radiocourtoisie.fr/courtoisie.m3u"

class Radio {
	static let loadFile = "loadfile"
	
	static func execute(_ status: Int32) throws {
		guard status >= 0 else {
			throw RadioError.Mpv(message: String(cString: mpv_error_string(status)))
		}
	}
	
	let handle = mpv_create()
	let queue = DispatchQueue(label: "Radio event loop")
	
	init() throws {
		try Radio.execute(mpv_initialize(handle))
		
		queue.async {
			while true {
				let eventID = mpv_wait_event(self.handle, Double.greatestFiniteMagnitude).pointee.event_id.rawValue
				print("mpv:", Event(rawValue: eventID) ?? "Unknown event")
			}
		}
	}
	
	func setChannel(to url: String) throws {
		try Radio.execute(mpv_command_string(handle, "loadfile \(url)"))
	}
	
	func stop() throws {
		try Radio.execute(mpv_command_string(handle, "stop"))
	}
	
	func increaseVolume(value: Int8 = 2) throws {
		try Radio.execute(mpv_command_string(handle, "add volume \(value)"))
	}
	
	func decreaseVolume(value: Int8 = 2) throws {
		try increaseVolume(value: -value)
	}
}

enum RadioError: Error {
	case Mpv(message: String)
}
