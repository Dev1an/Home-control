import Dispatch
import Foundation

public enum EventSourceState {
	case connecting
	case open
	case closed
}

open class EventSource: NSObject, URLSessionDataDelegate {
	static let DefaultsKey = "com.inaka.eventSource.lastEventId"
	
	let url: URL
	fileprivate let lastEventIDKey: String
	fileprivate let receivedString: String?
	fileprivate var onOpenCallback: ((Void) -> Void)?
	fileprivate var onErrorCallback: ((Error?) -> Void)?
	fileprivate var onMessageCallback: ((_ id: String?, _ event: String?, _ data: String?) -> Void)?
	open internal(set) var readyState: EventSourceState
	open fileprivate(set) var retryTime = 3000
	fileprivate var eventListeners = Dictionary<String, (_ id: String?, _ event: String?, _ data: String?) -> Void>()
	fileprivate var headers: Dictionary<String, String>
	internal var urlSession: Foundation.URLSession?
	internal var task: URLSessionDataTask?
	fileprivate var operationQueue: OperationQueue
	fileprivate var errorBeforeSetErrorCallBack: Error?
	internal var receivedDataBuffer: Data
	fileprivate let uniqueIdentifier: String
	fileprivate let validNewlineCharacters = ["\r\n", "\n", "\r"]
	
	var event = Dictionary<String, String>()
	
	
	public init(url: String, headers: [String : String] = [:]) {
		
		self.url = URL(string: url)!
		self.headers = headers
		self.readyState = EventSourceState.closed
		self.operationQueue = OperationQueue()
		self.receivedString = nil
		self.receivedDataBuffer = Data()
		
		
		var port = ""
		if let optionalPort = self.url.port {
			port = String(optionalPort)
		}
		let relativePath = self.url.relativePath
		let host = self.url.host ?? ""
		
		self.uniqueIdentifier = "\(String(describing: self.url.scheme)).\(host).\(port).\(relativePath)"
		self.lastEventIDKey = "\(EventSource.DefaultsKey).\(self.uniqueIdentifier)"
		
		super.init()
		self.connect()
	}
	
	//Mark: Connect
	
	func connect() {
		var additionalHeaders = self.headers
		if let eventID = self.lastEventID {
			additionalHeaders["Last-Event-Id"] = eventID
		}
		
		additionalHeaders["Accept"] = "text/event-stream"
		additionalHeaders["Cache-Control"] = "no-cache"
		
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = TimeInterval(Int32.max)
		configuration.timeoutIntervalForResource = TimeInterval(Int32.max)
		configuration.httpAdditionalHeaders = additionalHeaders
		
		self.readyState = EventSourceState.connecting
		self.urlSession = newSession(configuration)
		self.task = urlSession!.dataTask(with: self.url)
		
		self.resumeSession()
	}
	
	internal func resumeSession() {
		self.task!.resume()
	}
	
	internal func newSession(_ configuration: URLSessionConfiguration) -> Foundation.URLSession {
		return Foundation.URLSession(configuration: configuration,
		                             delegate: self,
		                             delegateQueue: operationQueue)
	}
	
	//Mark: Close
	
	open func close() {
		self.readyState = EventSourceState.closed
		self.urlSession?.invalidateAndCancel()
	}
	
	fileprivate func receivedMessageToClose(_ httpResponse: HTTPURLResponse?) -> Bool {
		guard let response = httpResponse  else {
			return false
		}
		
		if response.statusCode == 204 {
			self.close()
			return true
		}
		return false
	}
	
	//Mark: EventListeners
	
	open func onOpen(_ onOpenCallback: @escaping ((Void) -> Void)) {
		self.onOpenCallback = onOpenCallback
	}
	
	open func onError(_ onErrorCallback: @escaping ((Error?) -> Void)) {
		self.onErrorCallback = onErrorCallback
		
		if let errorBeforeSet = self.errorBeforeSetErrorCallBack {
			self.onErrorCallback!(errorBeforeSet)
			self.errorBeforeSetErrorCallBack = nil
		}
	}
	
	open func onMessage(_ onMessageCallback: @escaping ((_ id: String?, _ event: String?, _ data: String?) -> Void)) {
		self.onMessageCallback = onMessageCallback
	}
	
	open func addEventListener(_ event: String, handler: @escaping ((_ id: String?, _ event: String?, _ data: String?) -> Void)) {
		self.eventListeners[event] = handler
	}
	
	open func removeEventListener(_ event: String) -> Void {
		self.eventListeners.removeValue(forKey: event)
	}
	
	open func events() -> Array<String> {
		return Array(self.eventListeners.keys)
	}
	
	//MARK: URLSessionDataDelegate
	
	open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		if self.receivedMessageToClose(dataTask.response as? HTTPURLResponse) {
			return
		}
		
		if self.readyState != EventSourceState.open {
			return
		}
		
		self.receivedDataBuffer.append(data)
		let eventStream = extractEventsFromBuffer()
		self.parseEventStream(eventStream)
	}
	
	open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
		completionHandler(URLSession.ResponseDisposition.allow)
		
		if self.receivedMessageToClose(dataTask.response as? HTTPURLResponse) {
			return
		}
		
		self.readyState = EventSourceState.open
		if self.onOpenCallback != nil {
			DispatchQueue.main.async {
				self.onOpenCallback!()
			}
		}
	}
	
	open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		self.readyState = EventSourceState.closed
		
		if self.receivedMessageToClose(task.response as? HTTPURLResponse) {
			return
		}
		
		if error == nil || (error! as! NSError).code != NSURLErrorCancelled {
			let nanoseconds = Double(self.retryTime) / 1000.0
			let delayTime = DispatchTime.now() + nanoseconds
			DispatchQueue.main.asyncAfter(deadline: delayTime) {
				self.connect()
			}
		}
		
		DispatchQueue.main.async {
			if let errorCallback = self.onErrorCallback {
				errorCallback(error)
			} else {
				self.errorBeforeSetErrorCallBack = error
			}
		}
	}
	
	//MARK: Helpers
	
	fileprivate func extractEventsFromBuffer() -> [String] {
		var events = [String]()
		
		// Find first occurrence of delimiter
		var searchRange = Range(0 ..< receivedDataBuffer.endIndex)
		while let foundRange = searchForEventInRange(searchRange) {
			// Append event
			if foundRange.lowerBound > searchRange.lowerBound {
				let dataChunk = receivedDataBuffer.subdata(
					in: searchRange.lowerBound ..< foundRange.lowerBound
				)
				
				events.append(String(data: dataChunk, encoding: .utf8)!)
			}
			// Search for next occurrence of delimiter
			searchRange = foundRange.upperBound ..< searchRange.upperBound
		}
		
		// Remove the found events from the buffer
		receivedDataBuffer.removeSubrange(0 ..< searchRange.lowerBound)
		
		return events
	}
	
	fileprivate func searchForEventInRange(_ searchRange: Range<Data.Index>) -> Range<Data.Index>? {
		let delimiters = validNewlineCharacters.map { "\($0)\($0)".data(using: String.Encoding.utf8)! }
		
		for delimiter in delimiters {
			if let foundRange = receivedDataBuffer.range(of: delimiter,
			                                          options: NSData.SearchOptions(),
			                                          in: searchRange) {
				return foundRange
			}
		}
		
		return nil
	}
	
	fileprivate func parseEventStream(_ events: [String]) {
		var parsedEvents: [(id: String?, event: String?, data: String?)] = Array()
		
		for event in events {
			if event.isEmpty {
				continue
			}
			
			if event.hasPrefix(":") {
				continue
			}
			
			if event.contains("retry:") {
				if let reconnectTime = parseRetryTime(event) {
					self.retryTime = reconnectTime
				}
				continue
			}
			
			parsedEvents.append(parseEvent(event))
		}
		
		for parsedEvent in parsedEvents {
			self.lastEventID = parsedEvent.id
			
			if parsedEvent.event == nil {
				if let data = parsedEvent.data, let onMessage = self.onMessageCallback {
					DispatchQueue.main.async {
						onMessage(self.lastEventID, "message", data)
					}
				}
			}
			
			if let event = parsedEvent.event, let data = parsedEvent.data, let eventHandler = self.eventListeners[event] {
				DispatchQueue.main.async {
					eventHandler(self.lastEventID, event, data)
				}
			}
		}
	}
	
	internal var lastEventID: String? {
		set {
			if let lastEventID = newValue {
				let defaults = UserDefaults.standard
				defaults.set(lastEventID, forKey: lastEventIDKey)
				defaults.synchronize()
			}
		}
		
		get {
			let defaults = UserDefaults.standard
			
			if let lastEventID = defaults.string(forKey: lastEventIDKey) {
				return lastEventID
			}
			return nil
		}
	}
	
	fileprivate func parseEvent(_ eventString: String) -> (id: String?, event: String?, data: String?) {
		var event = Dictionary<String, String>()
		
		for line in eventString.components(separatedBy: CharacterSet.newlines) {
			let (key, value) = self.parseKeyValuePair(line)
			
			if let key = key, let value = value {
				if let oldEvent = event[key] {
					event[key] = oldEvent + "\n" + value
				} else {
					event[key] = value
				}
			} else if key != nil && value == nil {
				event[key!] = ""
			}
		}
		
		return (event["id"], event["event"], event["data"])
	}
	
	fileprivate func parseKeyValuePair(_ line: String) -> (String?, String?) {
		if let colon = line.rangeOfCharacter(from: [":"])?.lowerBound {
			let key = line.substring(to: colon)
			let value: String
			let lineEnd = line.rangeOfCharacter(from: .newlines, range: colon..<line.endIndex)?.lowerBound
			value = line.substring(with: line.index(colon, offsetBy: 2) ..< (lineEnd ?? line.endIndex))
			return (key, value)
		} else {
			let lineEnd = line.rangeOfCharacter(from: .newlines)?.lowerBound
			return (line.substring(to: lineEnd ?? line.endIndex), nil)
		}
	}
	
	fileprivate func parseRetryTime(_ eventString: String) -> Int? {
		var reconnectTime: Int?
		let separators = CharacterSet(charactersIn: ":")
		if let milli = eventString.components(separatedBy: separators).last {
			let milliseconds = trim(milli)
			
			if let intMiliseconds = Int(milliseconds) {
				reconnectTime = intMiliseconds
			}
		}
		return reconnectTime
	}
	
	fileprivate func trim(_ string: String) -> String {
		return string.trimmingCharacters(in: CharacterSet.whitespaces)
	}
	
	class open func basicAuth(_ username: String, password: String) -> String {
		let authString = "\(username):\(password)"
		let authData = authString.data(using: String.Encoding.utf8)
		let base64String = authData!.base64EncodedString(options: [])
		
		return "Basic \(base64String)"
	}
}
