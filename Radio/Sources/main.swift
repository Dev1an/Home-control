let device: String
if CommandLine.arguments.count > 1 { device = CommandLine.arguments[1] }
else { device = "/dev/input/by-id/usb-flirc.tv_flirc-if01-event-kbd" }

print("using input device: ", device)

do {
	let radio = try Radio()
	
	do {
		try radio.setChannel(to: radioMaria)
	} catch RadioError.Mpv(let message) {
		print("Unable to play radio maria")
		print(message)
	}
	
	couple(remote: device, to: radio)
	
	print("\n")
	print("- - - - - - - - - - - - - - - - - -")
	print("Command line internet radio player\n")
	print("    Press F1 for RCF Bruxelles     ")
	print("      Press F2 for RCF Vendée      ")
	print("    Press F3 for Radio Maria BE    ")
	print("    Press F5 for Klara Continuo    ")
	print("- - - - - - - - - - - - - - - - - -")
	print("\n")
	
	coupleCloud(to: radio)
	
} catch RadioError.Mpv(let message) {
	print("Unable to initialise radio")
	print(message)
}


import Dispatch
dispatchMain()
