import Cmpv
import Dispatch

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
