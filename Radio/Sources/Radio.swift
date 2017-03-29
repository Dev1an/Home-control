//
//  String UnsafePointer.swift
//  Radio
//
//  Created by Damiaan on 29/03/17.
//
//

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
	
	init() throws {
		try Radio.execute(mpv_initialize(handle))
		
		DispatchQueue(label: "Radio event loop").async {
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
}

enum RadioError: Error {
	case Mpv(message: String)
}
