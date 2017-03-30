//
//  FirebaseEventSourceUpdate.swift
//  HomeControl
//
//  Created by Damiaan on 30/03/17.
//
//

import Foundation

struct Update {
	var path: String
	var data: Any
}

extension Update {
	init?(json: String) {
		guard let object = try? JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!) as? [String: Any] else {
			return nil
		}
		
		guard let root = object else {
			return nil
		}
		
		guard let path = root["path"] as? String else {
			return nil
		}
		
		guard let data = root["data"] else {
			return nil
		}
		
		self.path = path
		self.data = data
	}
}
