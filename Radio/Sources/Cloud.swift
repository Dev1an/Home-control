let streamHeaders = ["Accept": "text/event-stream"]

func coupleCloud(to radio: Radio) {
	EventSource(url: "https://homecontrol-f0066.firebaseio.com/Homes/0/Radios/0/currentChannel.json", headers: streamHeaders).addEventListener("put") { (_, _, data) in
		if let json = data, let url = Update(json: json)?.data as? String {
			do {
				print("Cloud wants to change the channel to", url)
				try radio.setChannel(to: url)
			} catch RadioError.Mpv(let message) {
				print("Unable to change radio channel to", url)
				print(message)
			} catch {
				assert(false)
			}
		}
	}
}
