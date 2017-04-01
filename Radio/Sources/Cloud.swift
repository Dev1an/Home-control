import EventSource

func coupleCloud(to radio: Radio) {
	EventStream(from: "https://homecontrol-f0066.firebaseio.com/Home/0/Radio/0/currentChannel.json") { (event, data) in
		if event == "put", let url = Update(json: data)?.data as? String {
			do {
				print("Cloud wants to change the channel to", url)
				try radio.setChannel(to: url)
			} catch RadioError.Mpv(let message) {
				print("Unable to change radio channel to", url)
				print(message)
			} catch {
				assert(false)
			}
		} else {
			print("could not parse json")
		}
	}
}
